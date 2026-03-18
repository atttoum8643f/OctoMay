R <- 10 # nombres de sites
L <- 9 # nombres de repetition
n <- 100 # Observations


# Variables quantitatives 
hauteurbasseme <- runif(n, 0.5, 3)        # hauteur marée (m)
coefficientmaree <- runif(n, 20, 120)     # coefficient marée
temperature <- rnorm(n, 27, 2)            # température (°C)
lat <- runif(n, -13.1, -12.6)             # latitude (Mayotte approx)
lon <- runif(n, 45.0, 45.3)               # longitude


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
date_rep <- c("01/02/2025","01/03/2025","01/04/2025","01/05/2025","01/06/2025",
              "01/07/2025","01/08/2025","01/09/2025","01/10/2025")


# Identifiants
ID <- paste0("Id",1:n)



# Simulation
set.seed(8080)

turbidite <- sample(turbid,n, replace = TRUE, prob = c(0.399,0.601))
periode <- sample(period,n, replace = TRUE, prob = c(0.5,0.32,0.18))
etat <- sample(eta,n, replace = TRUE, prob = c(0.478,0.522))
precipitation <- sample(precipit,n, replace = TRUE, prob = c(0.45,0.38,0.17))
forcevent <- sample(fv,n, replace = TRUE, prob = c(0.12,0.21,0.17,0.24,0.26))
site <- sample(ste,n, replace = TRUE, prob = prob_ste)


#  ------------- MODELE D'ABONDANCE --------------

# Lambda dépend de certaines variables
lambda <- exp(1 +
                0.3 * (turbidite == "sale") +
                0.2 * (periode == "vacance") -
                0.01 * coefficientmaree +
                0.05 * temperature)

# Abondance réelle
N <- rpois(n, lambda)


#  ------------- MODELE DE DETECTION --------------

# Probabilité de détection
p <- plogis(-0.5 +
              0.4 * (etat == "terminer") -
              0.3 * (precipitation == "PP") +
              0.2 * (forcevent == "moins2_1km"))

# Abondance observée
Y <- rbinom(n, size = N, prob = p)