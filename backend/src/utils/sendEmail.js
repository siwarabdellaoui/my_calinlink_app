const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
    // Créer un transporteur basé sur les variables d'environnement
    const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST || 'smtp.gmail.com',
        port: process.env.SMTP_PORT || 587,
        secure: process.env.SMTP_PORT == 465, // true for 465, false for other ports
        auth: {
            user: process.env.SMTP_USER, 
            pass: process.env.SMTP_PASS, 
        },
    });

    const mailOptions = {
        from: `CâlinLink <${process.env.SMTP_USER || 'no-reply@calinlink.fr'}>`,
        to: options.email,
        subject: options.subject,
        text: options.message,
    };

    await transporter.sendMail(mailOptions);
};

module.exports = sendEmail;
