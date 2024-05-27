
#!/bin/bash

# Log to a file for debugging
exec > /tmp/weatherdunst.log 2>&1

# Function to handle errors
handle_error() {
    echo "Error: $1" >&2
    exit 1
}

# OpenWeatherMap API key and city
API_KEY="4d7a01d7c15169baec59b460aa4f7ac6"
CITY="jacksonville"
UNITS="imperial"  # Units: imperial (Fahrenheit) or metric (Celsius)

# Function to fetch weather data from OpenWeatherMap API
fetch_weather() {
    # Fetch weather data
    weather=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=$CITY&appid=$API_KEY&units=$UNITS")

    # Parse JSON response
    temperature=$(jq -r '.main.temp' <<< "$weather")
    description=$(jq -r '.weather[0].description' <<< "$weather")
    icon=$(jq -r '.weather[0].icon' <<< "$weather")

    # Define emojis for weather conditions
    case "$icon" in
        "01d") emoji="🌞";;   # clear sky (day)
        "01n") emoji="🌙";;   # clear sky (night)
        "02d") emoji="⛅";;   # few clouds (day)
        "02n") emoji="🌙⛅";; # few clouds (night)
        "03d" | "03n") emoji="🌥️";;  # scattered clouds
        "04d" | "04n") emoji="☁️";;  # broken clouds
        "09d" | "09n") emoji="🌧️";;  # shower rain
        "10d" | "10n") emoji="🌦️";;  # rain
        "11d" | "11n") emoji="🌩️";;  # thunderstorm
        "13d" | "13n") emoji="🌨️";;  # snow
        "50d" | "50n") emoji="🌫️";;  # mist
        *) emoji="❓";;        # unknown
    esac

    # Display weather notification using Dunst
    dunstify -u normal -t 5000 "Weather in $CITY" "Temperature: $temperature°F\nDescription: $description $emoji"
}

# Function to check for severe weather alerts
check_severe_weather() {
    # Fetch weather data
    weather=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=$CITY&appid=$API_KEY&units=$UNITS")

    # Check if severe weather conditions are detected (ID from 200 to 699)
    is_severe=$(jq -r '.weather[0].id' <<< "$weather")
    if [ "$is_severe" -ge 200 ] && [ "$is_severe" -lt 700 ]; then
        # Display severe weather alert
        fetch_weather
    fi
}

# Function to play sound alert on login
play_login_sound() {
    local sound_file="/home/swav/Music/weathersound.wav"
    if [ -f "$sound_file" ]; then
        paplay "$sound_file" || handle_error "Failed to play login sound"
    else
        echo "Error: Sound file not found" >&2
    fi
}

# Fetch weather data and display on login
fetch_weather

# Play login sound
play_login_sound

# Check for severe weather alerts 1-2 times
for ((i=0; i<2; i++)); do
    check_severe_weather
done

