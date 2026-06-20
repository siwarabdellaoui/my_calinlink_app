class BaseController {
    sendSuccess(res, data, statusCode = 200) {
        return res.status(statusCode).json(data);
    }

    sendError(res, message, statusCode = 500) {
        return res.status(statusCode).json({ message });
    }
}

module.exports = BaseController;
