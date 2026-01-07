Config = Config or {}

-- Enable or disable debug mode
Config.Debug = false

-- Binocular settings
Config.Binoculars = {
    normal = {
        zoom = false,
        baseFov = 38.0,
        swayMultiplier = 0.35,
        distancePrecision = 5.0,
        compassMode = "cardinal"
    },
    improved = {
        zoom = true,
        minFov = 15.0,
        maxFov = 50.0,
        zoomStep = 2.5,
        swayMultiplier = 0.14,
        distancePrecision = 1.0,
        compassMode = "degrees"
    }
}