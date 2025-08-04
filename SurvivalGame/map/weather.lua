local weather = {}
weather.current_weather_timer = 0

weather.weather_types = {
    ["Storm"] = {
        emission_rate = 150,
        particle_img = "assets/particles/rainparticle.png",
        spawn_interval1 = 0.0,
        spawn_interval2 = 0.33,
        duration_s = 10,
        angle_min = -50,
        angle_max = 50,
    },
    ["Rain"] = {
        emission_rate = 100,
        particle_img = "assets/particles/rainparticle.png",
        spawn_interval1 = 0.33,
        spawn_interval2 = 0.66,
        duration_s = 10,
        angle_min = -20,
        angle_max = 20,

    },
    ["Sunny"] = {
        emission_rate = 0,
        particle_img = "",
        spawn_interval1 = 0.66,
        spawn_interval2 = 1.0,
        duration_s = 10,
        angle_max=0,
        angle_min=0,
    }
}

weather.current = {
    name = "Sunny",
    data = weather.weather_types["Sunny"],
}

local function pick_random_weather()
    local r = love.math.random()
    for name, data in pairs(weather.weather_types) do
        if r >= data.spawn_interval1 and r < data.spawn_interval2 then
            weather.current_weather_timer = data.duration_s
            return name, data
        end
    end
    weather.current_weather_timer = weather.weather_types["Sunny"].duration_s
    return "Sunny", weather.weather_types["Sunny"]
end

function weather.update(dt)
    weather.current_weather_timer = weather.current_weather_timer - dt
    if weather.current_weather_timer <= 0 then
        local name, data = pick_random_weather()
        weather.current.name = name
        weather.current.data = data
        weather.current.timer = data.duration_s
        setup_particle(data)
    end
end

return weather
