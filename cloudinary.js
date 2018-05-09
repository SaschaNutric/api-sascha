const cloudinary = require('cloudinary')

cloudinary.config({
    cloud_name: "saschanutric",
    api_key: "565694154585139",
    api_secret: "CK92tHPcBVpM6HlZWtM4QgXQegU"
})

module.exports = cloudinary