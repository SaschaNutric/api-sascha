const cloudinary = require('cloudinary')

cloudinary.config({
    cloud_name: "saschanutric",
    api_key: "144681414132155",
    api_secret: "Orb7j35wQ0up7f6UpTZIiV4eUt4"
})

module.exports = cloudinary