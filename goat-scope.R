# Generating a 'trelliscope' for Mountain Goats songs with data from Spotify.
# See README for explanation.

library(trelliscopejs)
library(dplyr)
library(readr)
library(tidyr)

raw_goat <- read_rds("data/goat_discography.RDS")  # pre-gathered dataset

small_goat <- raw_goat %>% 
  unnest(available_markets) %>%
  filter(available_markets == "US") %>%
  select(
    track_name, album_name, track_n, album_release_year,  # track detail
    duration_ms, key_mode, time_signature, # musical info
    danceability, energy, speechiness, acousticness,  # audio features
    instrumentalness, liveness, valence, loudness  # audio features
  ) %>%
  arrange(desc(energy))

goat_pics <- raw_goat %>%
  unnest(album_images) %>%  # unnest dataframe of URLs
  filter(width == 640) %>%  # just the largest images
  select(album_name, url) %>%  # simplify dataset
  distinct(album_name, .keep_all = TRUE)  # one unique entry per album

small_goat_pics <- left_join(small_goat, goat_pics, by = "album_name")

prepared_goat <- small_goat_pics %>% 
  mutate(panel = img_panel(url)) %>%  # identify as viz for panel
  rename_all(tools::toTitleCase) %>%
  rename(
    Track = Track_name,
    Album = Album_name,
    `Track #` = Track_n,
    Year = Album_release_year,
    `Duration (ms)` = Duration_ms,
    `Key mode` = Key_mode,
    `Time sig` = Time_signature
  ) %>% 
  select(-Url)

trelliscope(
  prepared_goat,
  name = "The Mountain Goats discography",
  desc = "Explore the Mountain Goats backcatalogue and filter and sort by audio features",
  md_desc = "[The Mountain Goats](http://www.mountain-goats.com/) are a band. Data were collected from [Genius](https://genius.com/) and [Spotify](https://www.spotify.com/) APIs using the [{genius}](https://github.com/josiahparry/genius) and [{spotifyr}](https://www.rcharlie.com/spotifyr/) R packages, respectively.",
  nrow = 2, ncol = 5,  # arrangement of panels
  state = list(labels = c("Track", "Album", "Track #", "Year", "Energy")),  # display on panels
  path = "docs"
)
