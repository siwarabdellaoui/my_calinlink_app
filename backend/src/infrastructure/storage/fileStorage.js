// Gestion du stockage de fichiers (S3, Cloudinary, ou stockage local)

class FileStorage {
    async uploadFile(fileBuffer, filename) {
        console.log(`[Mock Storage] Téléchargement du fichier ${filename}`);
        return `https://storage.mock.com/${filename}`;
    }

    async deleteFile(fileUrl) {
        console.log(`[Mock Storage] Suppression du fichier ${fileUrl}`);
        return true;
    }
}

module.exports = new FileStorage();
