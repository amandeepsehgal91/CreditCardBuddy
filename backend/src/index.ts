import express from 'express';
import cors from 'cors';
import dashboardRouter from './dashboard';

const app = express();
const port = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send({ status: 'Credit Card Buddy API', version: '0.1.0' });
});

app.get('/health', (req, res) => {
  res.send({ status: 'ok' });
});

app.use('/dashboard', dashboardRouter);

app.listen(port, () => {
  console.log(`Server listening on http://localhost:${port}`);
});
