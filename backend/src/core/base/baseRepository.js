class BaseRepository {
    constructor(model) {
        this.model = model;
    }

    async findById(id) {
        return await this.model.findById(id);
    }

    async findAll(filter = {}) {
        return await this.model.find(filter);
    }

    async create(data) {
        return await this.model.create(data);
    }

    async updateById(id, data) {
        return await this.model.findByIdAndUpdate(id, data, { new: true });
    }

    async deleteById(id) {
        return await this.model.findByIdAndDelete(id);
    }
}

module.exports = BaseRepository;
