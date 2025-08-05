const express = require('express');
const { db } = require('./firebase/firebase');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});

app.get('/getMesas', async (req, res) => {
    const snapshot = await db.collection('Mesas').get();
    const items = snapshot.docs.map(doc => ({ 
        numMesa: doc.data().numMesa }));
    res.json(items);
});

