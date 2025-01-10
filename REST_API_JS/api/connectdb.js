const mongoose = require('mongoose');

const dbURI = process.env.MONGODB_URI || "mongodb+srv://agungMq135:agungmq135@cluster0.h9eyb.mongodb.net/sensor_data?retryWrites=true&w=majority&appName=Cluster0";
let isConnected = false;

/**
 * Fungsi untuk koneksi ke database MongoDB
 */
async function connectToDatabase() {
    if (isConnected) return;
    await mongoose.connect(dbURI, { useNewUrlParser: true, useUnifiedTopology: true });
    isConnected = true;
    console.log("MongoDB connected successfully");
}

module.exports = connectToDatabase;
