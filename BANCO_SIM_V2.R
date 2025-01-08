#### PACOTES ####

#INSTALANDO PACOTES
install.packages("remotes")
remotes::install_github("rfsaldanha/microdatasus")
install.packages("summarytools")
install.packages("writexl")
install.packages("openxlsx")
install.packages("readxl")
install.packages("scales")
install.packages("cobalt")

#CARREGANDO PACOTES
library(microdatasus)
library(summarytools)
library(dplyr)
library(writexl)
library(openxlsx)
library(readxl)
library(scales)
library(MatchIt)
library(cobalt)

##### ORGANIZANDO O BANCO DE DADOS SIM #####

# Criando data frame
sim <- fetch_datasus(year_start = 2022, year_end = 2022,
                     information_system = "SIM-DO" )


# Criando data frame somente com mortes de mulheres e excluindo colunas que não serão usadas

sim_fem <- subset(sim, SEXO != 0 & SEXO != 1, 
                  select = -c(ORIGEM, TIPOBITO, NATURAL, HORAOBITO, ASSISTMED, CODMUNNATU, FONTE, SERIESCFAL, OCUP, CODESTAB, ESTABDESCR, QTDFILVIVO, GRAVIDEZ, SEMAGESTAC, TPMORTEOCO, DTNASC, ESC, IDADEMAE, OCUPMAE, ESCMAE, ESCMAE2010, SERIESCMAE, GESTACAO, PARTO, EXAME, CIRURGIA, NECROPSIA, CB_PRE, DTINVESTIG, LINHAA, LINHAB, LINHAC, LINHAD, LINHAII, FONTEINV, DTRECEBIM, CAUSAMAT, ESCMAEAGR1, DIFDATA, NUDIASOBCO, NUDIASOBIN, DTCADINV, TPOBITOCOR, STCODIFICA, CODIFICADO, VERSAOSIST, VERSAOSCB, ESCFALAGR1, STDOEPIDEM, QTDFILMORT, OBITOPARTO, PESO, OBITOGRAV, OBITOPUERP, ATESTANTE, COMUNSVOIM, NUMEROLOTE, TPPOS, FONTESINF, DTCONCASO, STDONOVA, STDOEPIDEM, MORTEPARTO, DTCADINF, TPNIVELINV, DTCONINV, TPRESGINFO, NUDIASINF, CONTADOR, ALTCAUSA, DTRECORIGA, ATESTADO))


# Excluindo o dígito da subcategoria da coluna CAUSABAS

sim_fem$CAUSA_NOVA <- substr(sim_fem$CAUSABAS, 1, nchar(sim_fem$CAUSABAS) - 1)


# Excluindo o primeiro dígito da coluna IDADE

sim_fem$IDADE_NOVA <- substr(sim_fem$IDADE, 1, nchar(sim_fem$IDADE) - 1)


# Criando uma coluna com a faixa etária

sim_fem$IDADE_NOVA <- as.numeric(sim_fem$IDADE_NOVA)

sim_fem <- mutate(sim_fem,
  faixa_etaria = case_when(
    IDADE_NOVA >= 0 & IDADE_NOVA <= 17 ~ "0 a 17 anos",
    IDADE_NOVA >= 18 & IDADE_NOVA <= 35 ~ "18 a 35 anos",
    IDADE_NOVA >= 36 & IDADE_NOVA <= 53 ~ "36 a 53 anos",
    IDADE_NOVA >= 54 & IDADE_NOVA <= 71 ~ "51 a 71 anos",
    IDADE_NOVA >= 72 ~ "72 anos ou mais"
  ))


# Criando um df apenas com as variáveis de agressão (Agressão - X85 a Y09)

cids_agressao=c("X85", "X86", "X87", "X88", "X89", "X90", "X91", "X92", "X93", "X94", "X95", "X96", "X97", "X98", "X99", "Y00", "Y01", "Y02", "Y03", "Y04", "Y05", "Y06", "Y07", "Y08", "Y09")

sim_fem_agr <- sim_fem %>% filter(CAUSA_NOVA %in% cids_agressao)

# Excluindo os acidentes e circunstância não determinada da coluna CIRCOBITO, para manter somente os homicídios

sim_fem_agr <- sim_fem_agr %>% 
  filter(!(CIRCOBITO %in% c(1, 9)) & !is.na(CIRCOBITO))

# Excluindo os dígitos da coluna CÓDIGO MUNICÍPIO para criar uma coluna com ESTADOS

sim_fem_agr$estados <- substr(sim_fem_agr$CODMUNOCOR, 1, nchar(sim_fem_agr$CODMUNOCOR) - 4)


##### UNINDO O BANCO DE DADOS SIM COM O BANCO DE DADOS DAS DDMS #####

# Importando o banco

banco_ddm <- read_excel("C:/Users/User/Documents/TCC MBA/DDM/banco_ddm.xlsx")

# Unindo ao sim_fem_agr

banco_ddm <- banco_ddm %>% rename(CODMUNOCOR = cod_ibge)

sim_fem_agr <- left_join(sim_fem_agr, banco_ddm, by = "CODMUNOCOR")

#Análises descritivas do banco de DDMs

cidades_ddm <- banco_ddm %>%
  group_by(cidade) %>%
  summarise(Frequencia = n())

write_xlsx(cidades_ddm, "cidades_ddm.xlsx")


##### ANÁLISES DESCRITIVAS #####

summarytools::view(dfSummary(banco_sim_2))

# Se quiser apenas ver o html
view(summary)

freq_agressao <- table(sim_fem_agr$CAUSA_NOVA)

#Tabelas úteis
numero_cids <- sim_fem_agr %>%
  group_by(CAUSA_NOVA) %>%
  summarise(Frequencia = n())

write_xlsx(numero_cids, "numero_cids.xlsx")

municipios <- sim_fem_agr %>%
  group_by(CODMUNOCOR) %>%
  summarise(Frequencia = n())

write_xlsx(municipios, "municipios.xlsx")

estados <- sim_fem_agr %>%
  group_by(estados) %>%
  summarise(Frequencia = n())

write_xlsx(estados, "estados.xlsx")

raca <- sim_fem_agr %>%
  group_by(RACACOR) %>%
  summarise(Frequencia = n())

write_xlsx(estados, "estados.xlsx")

faixa_etaria <- sim_fem_agr %>%
  group_by(faixa_etaria) %>%
  summarise(Frequencia = n())

write_xlsx(faixa_etaria, "faixa_etaria.xlsx")

## Importar o banco da população feminina para calcular a % de óbitos sobre a população

# Importando o banco

pop_fem <- read_excel("C:/Users/User/Documents/TCC MBA/IBGE/pop_fem.xlsx")

# Criando uma coluna com a proporção de feminicícios por mil habitantes

sim_fem_agr <- sim_fem_agr %>%
  mutate(fem_pop_mil = scales::number((Frequencia.x / n_mulheres)*1000, accuracy = 0.0001, decimal.mark = "."))

# Unindo à tabela municipios

sim_fem_agr <- left_join(municipios, sim_fem_agr, by = "CODMUNOCOR")

# Unindo o banco de ddms

banco_ddm <- banco_ddm %>%
  rename(CODMUNOCOR =cod_ibge)

sim_fem_agr <- left_join(sim_fem_agr, banco_ddm, by = "CODMUNOCOR")

# Substituindo NA por "não" na coluna tem_ddm
sim_fem_agr <- sim_fem_agr %>%
  mutate(tem_ddm = ifelse(is.na(tem_ddm.x), "nao", as.character(tem_ddm.x)))

# Adicionar a coluna 'regiao' com base na coluna 'estado'
sim_fem_agr <- sim_fem_agr %>%
  mutate(
    regiao = case_when(
      estado %in% c("SP", "RJ", "MG", "ES") ~ "Sudeste",
      estado %in% c("BA", "SE", "AL", "PE", "PB", "MA", "PI", "RN", "CE") ~ "Nordeste",
      estado %in% c("RS", "SC", "PR") ~ "Sul",
      estado %in% c("MS", "MT", "GO", "DF") ~ "Centro-Oeste",
      estado %in% c("AC", "AM", "PA", "RO", "RR", "AP", "TO") ~ "Norte",
      TRUE ~ NA_character_  # Caso não haja correspondência
    )
  )


# Unindo o banco de IDH

sim_fem_agr <- left_join(sim_fem_agr, banco_idhm, by = "CODMUNOCOR")

# Verificar se há valores infinitos
sum(is.na(mun_pop_fem$idhm.x)) # Contar os valores NA
sum(!is.finite(mun_pop_fem$idhm.x)) # Contar valores não finitos

# Calculando a média de feminicídios para municípios com e sem ddm

medias_fem <- sim_fem_agr %>%
  group_by(tem_ddm) %>%
  summarize(media_frequencia = mean(Frequencia.x, na.rm = TRUE))

print(medias_fem)

# Calculando a média da proporção de feminicídios para municípios com e sem ddm

sim_fem_agr$fem_pop_mil <- as.numeric(sim_fem_agr$fem_pop_mil)

sim_fem_agr$tem_ddm <- ifelse(is.na(sim_fem_agr$tem_ddm), "nao", sim_fem_agr$tem_ddm)
sim_fem_agr$qtd_ddm <- ifelse(is.na(sim_fem_agr$qtd_ddm), "0", sim_fem_agr$sim_fem_agr$qtd_ddm)

medias <- sim_fem_agr %>%
  group_by(tem_ddm) %>%
  summarize(media_fem_pop = mean(fem_pop_mil, na.rm = TRUE))

print(medias)

#### PROPENSITY SCORE MATCHING ####

# Transformando as variáveis em dummies

sim_fem_agr$treat <- ifelse(!is.na(sim_fem_agr$tem_ddm) & sim_fem_agr$tem_ddm == 'ddm', 1, 0)

sim_fem_agr <- sim_fem_agr %>%
  mutate(regiao_dum = case_when(
   regiao == "Norte" ~ 1,
   regiao == "Nordeste" ~ 2,
   regiao == "Centro-Oeste" ~ 3,
   regiao == "Sudeste" ~ 4,
    TRUE ~ NA_real_
  ))

sim_fem_agr$regiao_dum <- as.numeric(sim_fem_agr$regiao_dum)

# Excluindo linhas que tem NA na coluna n_mulheres

sim_fem_agr <- sim_fem_agr[sim_fem_agr$CODMUNOCOR != 120000, ]
sim_fem_agr <- sim_fem_agr[!is.na(sim_fem_agr$idhm) & !is.na(sim_fem_agr$idhm_educ), ]

# Testando modelos e fórmulas de pareamento!

# Nearest: Via chatgpt 

match_v1 <- matchit(treat ~ n_mulheres + regiao + idhm + idhm_educ, data = sim_fem_agr, method = "nearest", estimand = "ATT")
match_summary_v1 <- summary(match_v1, standardize = TRUE, estimand = "ATT")

# Calculando o ATT

att <- with(match_v1, mean(Frequencia[treat == 1]) - mean(Frequencia[treat == 0]))
print(att)


print(match_summary_1)

# Separar as bases com observações com matching

matched_data <- match.data(match_model)

write_xlsx(matched_data, "matched_data.xlsx")

matched_data_2 <- match.data(match_model_2)

write_xlsx(matched_data_2, "matched_data_2.xlsx")

# Calculando o ATT

att <- with(matched_data_2, mean(Frequencia[treat == 1]) - mean(Frequencia[treat == 0]))
print(att)


# Nearest: documentação

match_v2 <- matchit(treat ~ n_mulheres + regiao + idhm + idhm_educ, 
                    data = sim_fem_agr, 
                    method = "nearest", 
                    distance = "glm", 
                    link = "logit", 
                    distance.options = list(), 
                    estimand = "ATT", 
                    exact = NULL, 
                    mahvars = NULL, 
                    antiexact = NULL, 
                    discard = "none", 
                    reestimate = FALSE, 
                    s.weights = NULL, 
                    replace = TRUE, 
                    m.order = NULL, 
                    caliper = NULL, 
                    ratio = 1, 
                    min.controls = NULL, 
                    max.controls = NULL, 
                    verbose = FALSE)

match_summary_v2 <- summary(match_v2, standardize = TRUE, estimand = "ATT")
print(match_summary_v2)

matched_data_2 <- match.data(match_v2)

att <- with(matched_data_v2, mean(fem_pop_mil[treat == 1]) - mean(fem_pop_mil[treat == 0]))
print(att)

# Subclass: documentação

match_v3 <- matchit(treat ~ n_mulheres + regiao + idhm + idhm_educ,
                    data = sim_fem_agr, 
                    method = "subclass", 
                    distance = "glm", 
                    link = "logit", 
                    distance.options = list(), 
                    estimand = "ATT", 
                    discard = "none", 
                    reestimate = FALSE, 
                    s.weights = NULL, 
                    verbose = FALSE)

match_summary_v3 <- summary(match_v3, standardize = TRUE, estimand = "ATT")
print(match_summary_v3)

# Separar as bases com observações com matching

matched_data_3 <- match.data(match_v3)

att_3 <- with(matched_data_3, mean(Frequencia.x[treat == 1]) - mean(Frequencia.x[treat == 0]))
print(att_3)

# Separar as bases com observações com matching

matched_data_v2 <- match.data(match_v2)

write_xlsx(matched_data, "matched_data.xlsx")

# Calculando o ATT

att <- with(matched_data_v2, mean(Frequencia[treat == 1]) - mean(Frequencia[treat == 0]))
print(att)

