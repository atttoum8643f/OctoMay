
# -------- paramètres --------

library(dplyr)
library(tidyr)


# -------- Sites --------

ste <- c("Boueni","Aeroport","Mtsangamouji","Mtsangamboi","Mtsangadoua",
         "Sada","Acoua","Sohoa","nyambadao","Mtsapere")

set.seed(808)

# -------- dates : 7 jours par mois (2023 → 2025) --------

mois_seq <- seq(
  from = as.Date("2023-01-01"),
  to   = as.Date("2025-12-01"),
  by   = "month"
)

jours_terrain <- function(date_mois) {
  debut <- date_mois
  fin <- seq(date_mois, length = 2, by = "month")[2] - 1
  
  jours <- seq(debut, fin, length.out = 7)
  as.Date(round(jours), origin = "1970-01-01")
}

date_rep <- do.call(c, lapply(mois_seq, jours_terrain))

# -------- coordonnées des sites --------

coord_sites <- data.frame(
  site = ste,
  latitude = c(-12.79, -12.80, -12.73, -12.70, -12.72,
               -12.85, -12.72, -12.74, -12.83, -12.79),
  longitude = c(45.28, 45.27, 45.20, 45.18, 45.22,
                45.12, 45.08, 45.10, 45.23, 45.19)
)

# -------- abondance (niveau site AVANT échantillonnage) --------

turbid <- c("claire","sale")

cov_site <- data.frame(
  site = ste,
  turbidite_site = sample(turbid, length(ste), replace = TRUE)
)

lambda_site <- exp(1 +
                     0.5 * (cov_site$turbidite_site == "sale") +
                     rnorm(length(ste), 0, 0.3))

N_site <- rpois(length(ste), lambda_site)

# -------- PROBA DE VISITE dépend de l'abondance --------

proba_sites <- N_site / sum(N_site)

# -------- UNE VISITE = UNE DATE = UN SITE --------

data_simul <- data.frame(
  date = date_rep,
  site = sample(ste, length(date_rep), replace = TRUE, prob = proba_sites)
)

n <- nrow(data_simul)

# -------- ajout coordonnées + covariables site --------

data_simul <- data_simul %>%
  left_join(coord_sites, by = "site") %>%
  left_join(cov_site, by = "site")

data_simul$N <- N_site[match(data_simul$site, ste)]

# -------- covariables visite --------

period <- c("semaine","week-end","vacance")
eta <- c("vide","terminer")
precipit <- c("PP","PF","PE") 
fv <- c("moins2_1km","entre_1&5km","entre_6&11km","entre_12&19km","entre_20&28km")

data_simul$turbidite <- sample(turbid, n, replace = TRUE)
data_simul$periode <- sample(period, n, replace = TRUE)
data_simul$etat <- sample(eta, n, replace = TRUE)
data_simul$precipitation <- sample(precipit, n, replace = TRUE)
data_simul$forcevent <- sample(fv, n, replace = TRUE)

data_simul$coefficientmaree <- runif(n, 20, 120)
data_simul$hauteurbassemer <- runif(n, 0.5, 3)
data_simul$temperature <- rnorm(n, 27, 2)

# -------- détection --------

p <- plogis(-0.5 +
              0.4 * (data_simul$etat == "terminer") -
              0.3 * (data_simul$precipitation == "PP") +
              0.2 * (data_simul$forcevent == "moins2_1km") +
              0.01 * data_simul$temperature)

# -------- observations --------

data_simul$nbindividus <- rbinom(
  n,
  size = data_simul$N,
  prob = p
)

# -------- format large --------

Y <- data_simul %>%
  mutate(date_char = format(date, "%d/%m/%Y")) %>%
  pivot_wider(
    id_cols = c(site, latitude, longitude),
    names_from = date_char,
    values_from = nbindividus,
    values_fill = list(nbindividus = 0)
  )
