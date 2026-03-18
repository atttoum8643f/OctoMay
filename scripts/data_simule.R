R <- 10 # nombres de sites
L <- 9 # nombres de repetition
n <- 100 # Observations


# modalites
turbid <- c("claire","sale")
period <- c("semaine","week-end","vacance")
eta <- c("vide","terminer")
precipit <- c("PP","PF","PE") 
fv <- c("moins2_1km","entre_1&5km","entre_6&11km","entre_12&19km",
        "entre_20&28km")
ste <- c("Boueni","Aeroport","Mtsangamouji","Mtsangamboi","Mtsangadoua","Sada",
         "Acoua","Sohoa","nyambadao","Mtsapere")

prob_ste <- c(0.17, 0.13, 0.09, 0.06, 0.10, 0.15, 0.06, 0.08, 0.09,0.07)


# date
date_rep <- c("02/2025","03/2025","04/2025","05/2025","06/2025",
              "07/2025","08/2025","09/2025","10/2025")

prob_dte <- c(0.17, 0.13, 0.09, 0.06, 0.10, 0.15, 0.06, 0.08, 0.16)


# Identifiants
ID <- paste0("Id",1:n)



# Simulation
set.seed(0808)
site <- sample(ste,n, replace = TRUE, prob = prob_ste)
date <- sample(date_rep,n, replace = TRUE, prob = prob_dte)

# dataframe
data_simul <- data.frame(ID=ID, site=site, date=date)

data_simul$turbidite <- sample(turbid,n, replace = TRUE, prob = c(0.399,0.601))
data_simul$periode <- sample(period,n, replace = TRUE, prob = c(0.5,0.32,0.18))
data_simul$etat <- sample(eta,n, replace = TRUE, prob = c(0.478,0.522))
data_simul$precipitation <- sample(precipit,n, replace = TRUE, prob = c(0.45,0.38,0.17))
data_simul$forcevent <- sample(fv,n, replace = TRUE, prob = c(0.12,0.21,0.17,0.24,0.26))



# Variables quantitatives 
set.seed(0808)
data_simul$hauteurbasseme <- runif(n, 0.5, 3)        # hauteur marée (m)
data_simul$coefficientmaree <- runif(n, 20, 120)     # coefficient marée
data_simul$temperature <- rnorm(n, 27, 2)            # température (°C)
data_simul$lat <- runif(n, -13.1, -12.6)             # latitude (Mayotte)
data_simul$lon <- runif(n, 45.0, 45.3)               # longitude (Mayotte)


#  ------------- Modele d'abondance --------------

# Lambda dépend de certaines variables
lambda <- exp(1 +
                0.3 * (data_simul$turbidite == "sale") +
                0.2 * (data_simul$periode == "vacance") -
                0.01 * data_simul$coefficientmaree +
                0.05 * data_simul$temperature)

# Abondance réelle
N <- rpois(n, lambda)


#  ------------- Modele de detection --------------

# Probabilité de détection
p <- plogis(-0.5 +
              0.4 * (data_simul$etat == "terminer") -
              0.3 * (data_simul$precipitation == "PP") +
              0.2 * (data_simul$forcevent == "moins2_1km"))

# Abondance observée
data_simul$nbindividus <- rbinom(n, size = N, prob = p)


#  ------------- Creation du tableau de donnee --------------

Y  <- data_simul %>%
  pivot_wider(
    id_cols = site,
    names_from = date,
    values_from = nbindividus,
    values_fn = sum
  )
