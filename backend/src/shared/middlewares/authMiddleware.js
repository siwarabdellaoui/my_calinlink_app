const jwt = require('jsonwebtoken');
const User = require('../../modules/users/models/User');

const protect = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            // "Bearer token_string" -> on split par espace et on prend [1]
            token = req.headers.authorization.split(' ')[1];

            // Décoder le token
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secretcalinlink123');

            // Rajouter l'utilisateur (sans le mot de passe) dans request
            const user = await User.findById(decoded.id).select('-password');
            
            if (!user) {
                return res.status(401).json({ message: 'Non autorisé, utilisateur non trouvé' });
            }

            if (user.sessionsValidAfter && decoded.iat) {
                // iat est en secondes, sessionsValidAfter en ms
                const iatMs = decoded.iat * 1000;
                if (iatMs < user.sessionsValidAfter.getTime()) {
                    return res.status(401).json({ message: 'Session invalide, veuillez vous reconnecter' });
                }
            }

            req.user = user;

            next();
        } catch (error) {
            console.error(error);
            res.status(401).json({ message: 'Non autorisé, échec du token' });
        }
    }

    if (!token) {
        res.status(401).json({ message: 'Non autorisé, pas de token' });
    }
};

module.exports = { protect };
