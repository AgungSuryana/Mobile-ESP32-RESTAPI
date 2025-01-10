const connectToDatabase = require('./connectdb');
const SensorData = require('./SensorModel'); 

/**
 * Handler untuk POST: Menyimpan data sensor baru ke database
 */
module.exports = async (req, res) => {
    try {
        await connectToDatabase(); 
        const { gasLevel } = req.body;

        if (gasLevel === undefined) {
            return res.status(400).json({ error: "Data tidak lengkap" });
        }

        const newSensorData = new SensorData({ gasLevel });
        await newSensorData.save();

        res.status(200).json({ message: "Data berhasil disimpan" });
    } catch (error) {
        console.error("Error while saving data:", error);
        res.status(500).json({ error: "Failed to save data" });
    }
};
