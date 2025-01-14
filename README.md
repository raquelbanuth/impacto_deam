# Impacto das delegacias da mulher na redução de mortes violentas de mulheres em municípios brasileiros

> Esse projeto foi realizado como meu trabalho de conclusão de curso para o MBA de Data Science e Analytics da USP/Esalq. 

Foi orientado pelo prof. [Daniel Alvarez Ribeiro](https://www.linkedin.com/in/daniel-alvarez-data/).

# 🎯 Objetivo
> Avaliar se as Delegacias Especializadas de Atendimento à Mulher (DEAM) são eficazes em ****diminuir** as taxas de feminicídio** nos municípios em que estão instaladas, e se esse equipamento de segurança pode **diminuir a probabilidade de ocorrência** de mortes de mulheres.

# 📚 Método
**Análise descritiva:** Foi feita uma análise descritiva dos dados de feminicídio para levantamento do perfil das vítimas de mortes violentas, características dos homicídios e dos municípios que têm delegacias da mulher.

**Propensity matching score:** técnica de avaliação de impacto que tem por objetivo comparar as taxas de feminicídio em municípios com e sem DEAM. O PMS compreende três etapas principais:
> 1. Cálculo do propensity score para cada município
>    Probabilidade condicional de cada indivíduo receber o tratamento com base em características observáveis
> 2. Pareamento
>    Entre indivíduos do grupo tratamento e controle que tenham propensities scores semelhantes
> 3. Cálculo do Average Treatment Effect on the Treated (ATT)
Estimativa do efeito do programa a partir da comparação entre municípios dos dois grupos


**Regressão logística binária:** Estimar a probabilidade de ocorrências de feminicídio em função da presença de delegacias no município.
> Variável dependente: Dummy que indica se o município teve ou não ocorrências de feminicídio no ano de 2022
> 0 = não teve ocorrências de feminicídios em 2022
> 1 = teve ao menos 1 ocorrência de feminicídio em 2022.

> Variáveis independentes: As mesmas utilizadas no propensity score matching + uma variável dummy que indica a presença de DEAMs no município:
> 0 = não há DEAMs no município
> 1 = há ao menos uma DEAM no município. 

# 🔎 Fontes dos dados

**Dados de feminicídios:** Extraídos do Sistema de Informações de Mortalidade (SIM) através do pacote [microdatasus](https://github.com/rfsaldanha/microdatasus)

**Levantamento de DEAMs:** Levantamento manual feito através de consultas aos sites das Secretarias de Segurança Pública de cada estado, sites da Polícia Civil Militar, Tribunal de Justiça, e notícias da imprensa sobre a presença de DEAMs no município.

# 📊 Resultados

Estima-se que as DEAMs evitaram a morte de **0,017 mulheres** a cada 1.000 habitantes de municípios com esse equipamento em 2022. Considerando que a população nas cidades com DEAM é de 111.443.402 habitantes, estima-se que as DEAMs tenham evitado a morte violenta de **1.894 mulheres** em 2022. 

No entanto, não há evidências que as DEAMs diminuam a probabilidade de ocorrência de feminicídios no município.

As DEAMs se mostram eficazes para reduzir casos de homicídio em cidades onde esse problema já acontece, mas não se pode afirmar que sua atuação seja eficaz num âmbito preventivo. Importância da atuação conjunta da rede, com equipamentos de saúde, segurança e assistência com competências específicas e distintas.






