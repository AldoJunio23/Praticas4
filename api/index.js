const express = require('express');
const { db } = require('./firebase/firebase');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

// Rota existente
app.get('/getMesas', async (req, res) => {
    try {
        const snapshot = await db.collection('Mesas').get();
        const items = snapshot.docs.map(doc => ({ 
            id: doc.id,
            numMesa: doc.data().numMesa,
            status: doc.data().status
        }));
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 1. Carregar dados de uma mesa específica
app.get('/mesa/:mesaId', async (req, res) => {
    try {
        const { mesaId } = req.params;
        const doc = await db.collection('Mesas').doc(mesaId).get();
        
        if (!doc.exists) {
            return res.status(404).json({ error: 'Mesa não encontrada' });
        }
        
        const mesaData = {
            id: doc.id,
            ...doc.data()
        };
        
        res.json(mesaData);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 2. Buscar pedidos ativos de uma mesa
app.get('/mesa/:mesaId/pedidos-ativos', async (req, res) => {
    try {
        const { mesaId } = req.params;
        const mesaRef = db.collection('Mesas').doc(mesaId);
        
        const pedidosSnapshot = await db.collection('Pedidos')
            .where('mesa', '==', mesaRef)
            .where('finalizado', '==', false)
            .get();
        
        const pedidos = pedidosSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            mesa: doc.data().mesa.id // Converter referência para ID
        }));
        
        res.json(pedidos);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 3. Buscar todos os pedidos de uma mesa (ativos e finalizados)
app.get('/mesa/:mesaId/todos-pedidos', async (req, res) => {
    try {
        const { mesaId } = req.params;
        const mesaRef = db.collection('Mesas').doc(mesaId);
        
        const pedidosSnapshot = await db.collection('Pedidos')
            .where('mesa', '==', mesaRef)
            .get();
        
        const pedidos = [];
        
        for (const doc of pedidosSnapshot.docs) {
            const pedidoData = doc.data();
            const pedido = {
                id: doc.id,
                ...pedidoData,
                mesa: pedidoData.mesa.id,
                produtos: []
            };
            
            // Carregar produtos do pedido
            if (pedidoData.listaProdutos && pedidoData.listaProdutos.length > 0) {
                for (const produtoRef of pedidoData.listaProdutos) {
                    const produtoDoc = await produtoRef.get();
                    if (produtoDoc.exists) {
                        pedido.produtos.push({
                            id: produtoDoc.id,
                            ...produtoDoc.data()
                        });
                    }
                }
            }
            
            pedidos.push(pedido);
        }
        
        res.json(pedidos);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 4. Criar novo pedido
app.post('/pedido', async (req, res) => {
    try {
        const { mesaId } = req.body;
        
        if (!mesaId) {
            return res.status(400).json({ error: 'mesaId é obrigatório' });
        }
        
        const mesaRef = db.collection('Mesas').doc(mesaId);
        
        // Verificar se a mesa existe
        const mesaDoc = await mesaRef.get();
        if (!mesaDoc.exists) {
            return res.status(404).json({ error: 'Mesa não encontrada' });
        }
        
        const novoPedido = {
            mesa: mesaRef,
            dataCriacao: new Date(),
            finalizado: false,
            listaProdutos: [],
            valorTotal: 0.0
        };
        
        const novoPedidoRef = await db.collection('Pedidos').add(novoPedido);
        
        res.json({
            id: novoPedidoRef.id,
            ...novoPedido,
            mesa: mesaId
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 5. Finalizar pedido
app.put('/pedido/:pedidoId/finalizar', async (req, res) => {
    try {
        const { pedidoId } = req.params;
        
        await db.collection('Pedidos').doc(pedidoId).update({
            finalizado: true,
            dataFinalizacao: new Date()
        });
        
        res.json({ message: 'Pedido finalizado com sucesso' });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 6. Alterar status da mesa
app.put('/mesa/:mesaId/status', async (req, res) => {
    try {
        const { mesaId } = req.params;
        const { status } = req.body;
        
        if (typeof status !== 'boolean') {
            return res.status(400).json({ error: 'Status deve ser true ou false' });
        }
        
        // Se estiver liberando a mesa (status = false), verificar se há pedidos em aberto
        if (!status) {
            const mesaRef = db.collection('Mesas').doc(mesaId);
            const pedidosSnapshot = await db.collection('Pedidos')
                .where('mesa', '==', mesaRef)
                .where('finalizado', '==', false)
                .get();
            
            if (!pedidosSnapshot.empty) {
                return res.status(400).json({ 
                    error: 'Não é possível liberar a mesa com pedidos em aberto' 
                });
            }
        }
        
        await db.collection('Mesas').doc(mesaId).update({ status });
        
        res.json({ 
            message: status ? 'Mesa ocupada' : 'Mesa liberada',
            status 
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 7. Buscar produtos consumidos por mesa (agregados)
app.get('/mesa/:mesaId/produtos-consumidos', async (req, res) => {
    try {
        const { mesaId } = req.params;
        const mesaRef = db.collection('Mesas').doc(mesaId);
        
        const pedidosSnapshot = await db.collection('Pedidos')
            .where('mesa', '==', mesaRef)
            .get();
        
        const produtoQuantidades = {};
        const produtoPrecos = {};
        const produtosDados = {};
        let total = 0.0;
        
        // Processar todos os pedidos
        for (const pedidoDoc of pedidosSnapshot.docs) {
            const pedido = pedidoDoc.data();
            const produtosRefs = pedido.listaProdutos || [];
            
            for (const produtoRef of produtosRefs) {
                const produtoDoc = await produtoRef.get();
                if (produtoDoc.exists) {
                    const produtoData = produtoDoc.data();
                    const produtoId = produtoDoc.id;
                    const preco = produtoData.valor || 0.0;
                    
                    // Atualizar contadores
                    produtoQuantidades[produtoId] = (produtoQuantidades[produtoId] || 0) + 1;
                    produtoPrecos[produtoId] = preco;
                    produtosDados[produtoId] = {
                        id: produtoId,
                        nome: produtoData.nome || 'Produto desconhecido',
                        preco: preco,
                        imagem: produtoData.imagem || ''
                    };
                    
                    total += preco;
                }
            }
        }
        
        // Montar lista final com quantidades e subtotais
        const produtosFinais = Object.keys(produtosDados).map(produtoId => ({
            ...produtosDados[produtoId],
            qtd: produtoQuantidades[produtoId],
            subtotal: produtoQuantidades[produtoId] * produtoPrecos[produtoId]
        }));
        
        res.json({
            produtos: produtosFinais,
            total: total
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 8. Buscar pedido específico com produtos
app.get('/pedido/:pedidoId', async (req, res) => {
    try {
        const { pedidoId } = req.params;
        const pedidoDoc = await db.collection('Pedidos').doc(pedidoId).get();
        
        if (!pedidoDoc.exists) {
            return res.status(404).json({ error: 'Pedido não encontrado' });
        }
        
        const pedidoData = pedidoDoc.data();
        const pedido = {
            id: pedidoDoc.id,
            ...pedidoData,
            mesa: pedidoData.mesa.id,
            produtos: []
        };
        
        // Carregar produtos do pedido
        if (pedidoData.listaProdutos && pedidoData.listaProdutos.length > 0) {
            for (const produtoRef of pedidoData.listaProdutos) {
                const produtoDoc = await produtoRef.get();
                if (produtoDoc.exists) {
                    pedido.produtos.push({
                        id: produtoDoc.id,
                        ...produtoDoc.data()
                    });
                }
            }
        }
        
        res.json(pedido);
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 9. Buscar pedido por mesa (para finalização)
app.get('/mesa/:mesaId/pedido-ativo', async (req, res) => {
    try {
        const { mesaId } = req.params;
        const mesaRef = db.collection('Mesas').doc(mesaId);
        
        const pedidosSnapshot = await db.collection('Pedidos')
            .where('mesa', '==', mesaRef)
            .where('finalizado', '==', false)
            .limit(1)
            .get();
        
        if (pedidosSnapshot.empty) {
            return res.status(404).json({ error: 'Nenhum pedido ativo encontrado' });
        }
        
        const pedidoDoc = pedidosSnapshot.docs[0];
        const pedidoData = pedidoDoc.data();
        
        const pedido = {
            id: pedidoDoc.id,
            ...pedidoData,
            mesa: pedidoData.mesa.id
        };
        
        res.json(pedido);
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 10. Atualizar valor total do pedido
app.put('/pedido/:pedidoId/valor-total', async (req, res) => {
    try {
        const { pedidoId } = req.params;
        const { valorTotal } = req.body;
        
        if (typeof valorTotal !== 'number') {
            return res.status(400).json({ error: 'Valor total deve ser um número' });
        }
        
        await db.collection('Pedidos').doc(pedidoId).update({
            valorTotal: valorTotal
        });
        
        res.json({ message: 'Valor total atualizado com sucesso' });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 11. Buscar todos os produtos (para adicionar ao pedido)
app.get('/produtos', async (req, res) => {
    try {
        const snapshot = await db.collection('Produtos').get();
        const produtos = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
        
        res.json(produtos);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 12. Adicionar produto ao pedido
app.post('/pedido/:pedidoId/produto', async (req, res) => {
    try {
        const { pedidoId } = req.params;
        const { produtoId } = req.body;
        
        if (!produtoId) {
            return res.status(400).json({ error: 'produtoId é obrigatório' });
        }
        
        const produtoRef = db.collection('Produtos').doc(produtoId);
        const pedidoRef = db.collection('Pedidos').doc(pedidoId);
        
        // Verificar se produto e pedido existem
        const [produtoDoc, pedidoDoc] = await Promise.all([
            produtoRef.get(),
            pedidoRef.get()
        ]);
        
        if (!produtoDoc.exists) {
            return res.status(404).json({ error: 'Produto não encontrado' });
        }
        
        if (!pedidoDoc.exists) {
            return res.status(404).json({ error: 'Pedido não encontrado' });
        }
        
        const pedidoData = pedidoDoc.data();
        const listaProdutos = pedidoData.listaProdutos || [];
        
        // Adicionar produto à lista
        listaProdutos.push(produtoRef);
        
        // Calcular novo valor total
        const produtoData = produtoDoc.data();
        const novoValorTotal = (pedidoData.valorTotal || 0) + (produtoData.valor || 0);
        
        await pedidoRef.update({
            listaProdutos: listaProdutos,
            valorTotal: novoValorTotal
        });
        
        res.json({ 
            message: 'Produto adicionado com sucesso',
            valorTotal: novoValorTotal
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// 13. Remover produto do pedido
app.delete('/pedido/:pedidoId/produto/:produtoId', async (req, res) => {
    try {
        const { pedidoId, produtoId } = req.params;
        
        const pedidoRef = db.collection('Pedidos').doc(pedidoId);
        const pedidoDoc = await pedidoRef.get();
        
        if (!pedidoDoc.exists) {
            return res.status(404).json({ error: 'Pedido não encontrado' });
        }
        
        const pedidoData = pedidoDoc.data();
        let listaProdutos = pedidoData.listaProdutos || [];
        
        // Encontrar e remover a primeira ocorrência do produto
        const produtoRef = db.collection('Produtos').doc(produtoId);
        const index = listaProdutos.findIndex(ref => ref.id === produtoId);
        
        if (index === -1) {
            return res.status(404).json({ error: 'Produto não encontrado no pedido' });
        }
        
        // Buscar dados do produto para calcular novo valor
        const produtoDoc = await produtoRef.get();
        const produtoData = produtoDoc.data();
        const valorProduto = produtoData.valor || 0;
        
        // Remover produto da lista
        listaProdutos.splice(index, 1);
        
        // Calcular novo valor total
        const novoValorTotal = Math.max(0, (pedidoData.valorTotal || 0) - valorProduto);
        
        await pedidoRef.update({
            listaProdutos: listaProdutos,
            valorTotal: novoValorTotal
        });
        
        res.json({ 
            message: 'Produto removido com sucesso',
            valorTotal: novoValorTotal
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});