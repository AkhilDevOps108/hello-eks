const express = require('express');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');

const app = express();
app.use(express.json());

const BUCKET = process.env.BUCKET;
const REGION = process.env.AWS_REGION || process.env.AWS_DEFAULT_REGION || 'ap-south-1';
const s3 = new S3Client({ region: REGION });

app.get('/', (_, res) => res.send('Hello from EKS + S3 👋'));
app.post('/upload', async (req, res) => {
  try {
    const key = `hello-${Date.now()}.txt`;
    const body = Buffer.from('uploaded from EKS pod');
    await s3.send(new PutObjectCommand({ Bucket: BUCKET, Key: key, Body: body }));
    res.json({ ok: true, key });
  } catch (e) {
    console.error(e);
    res.status(500).json({ ok: false, error: e.message });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`listening on ${PORT}`));
