const mongoose = require('mongoose');

/**
 * Schema untuk data sensor
 */
const sensorSchema = new mongoose.Schema({
    gasLevel: Number,
    timestamp: { type: Date, default: Date.now }
});

/**
 * Model untuk koleksi sensor_data
 */
const SensorData = mongoose.model('mq135', sensorSchema);

module.exports = SensorData;
