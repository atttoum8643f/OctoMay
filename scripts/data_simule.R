library(dplyr)
library(tidyr)

# -------- parametres --------

R <- 10
L <- 9

ste <- c("Boueni","Aeroport","Mtsangamouji","Mtsangamboi","Mtsangadoua",
         "Sada","Acoua","Sohoa","nyambadao","Mtsapere")

date_rep <- c("02/2025","03/2025","04/2025","05/2025","06/2025",
              "07/2025","08/2025","09/2025","10/2025")

turbid <- c("claire","sale")
period <- c("semaine","week-end","vacance")
eta <- c("vide","terminer")
precipit <- c("PP","PF","PE") 
fv <- c("moins2_1km","entre_1&5km","entre_6&11km","entre_12&19km","entre_20&28km")

# -------- structure site x date --------

data_simul <- expand.grid(site = ste, date = date_rep)
n <- nrow(data_simul)

set.seed(808)

# -------- covariables --------

data_simul$turbidite <- sample(turbid, n, replace = TRUE)
data_simul$periode <- sample(period, n, replace = TRUE)
data_simul$etat <- sample(eta, n, replace = TRUE)
data_simul$precipitation <- sample(precipit, n, replace = TRUE)
data_simul$forcevent <- sample(fv, n, replace = TRUE)

data_simul$coefficientmaree <- runif(n, 20, 120)
data_simul$hauteurbassemer <- runif(n, 0.5, 3)
data_simul$temperature <- rnorm(n, 27, 2)

# -------- abondance (niveau site) --------

cov_site <- data.frame(
  site = ste,
  turbidite_site = sample(turbid, R, replace = TRUE)
)

data_simul <- left_join(data_simul, cov_site, by = "site")

lambda_site <- exp(1 +
                     0.5 * (cov_site$turbidite_site == "sale") +
                     rnorm(R, 0, 0.3))

N_site <- rpois(R, lambda_site)

data_simul$N <- N_site[match(data_simul$site, ste)]

# -------- detection (niveau visite) --------

p <- plogis(-0.5 +
              0.4 * (data_simul$etat == "terminer") -
              0.3 * (data_simul$precipitation == "PP") +
              0.2 * (data_simul$forcevent == "moins2_1km") +
              0.01 * data_simul$temp)

# -------- observations --------

data_simul$nbindividus <- rbinom(n,
                                 size = data_simul$N,
                                 prob = p)

# -------- tableau final --------

Y <- data_simul %>%
  pivot_wider(
    id_cols = site,
    names_from = date,
    values_from = nbindividus,
    values_fill = 0
  )
