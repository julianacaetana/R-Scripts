######Carregando as bibliotecas#######

library(rjson)
library(dplyr)
library(stringr)
library(reshape2)
library(data.table)
library(XML)
library(rvest)
library(lubridate)


##### Define o workspace####

setwd("D:/Pós Graduação/Projeto Aplicado/Scraping/Dados Abertos BC/Outros Datasets")


#######  Definindo as fontes ########

lista.datasets <-
  as.data.frame(fromJSON(
    readLines("http://dadosabertos.bcb.gov.br/api/action/package_list")
  )$result, stringsAsFactors = F)
names(lista.datasets) <- "dataset"
lista.datasets <- bind_cols(lista.datasets,
                            data.frame(sgs = str_detect(lista.datasets$dataset, "[0-9]-")))
lista.datasets <- filter(lista.datasets, lista.datasets$sgs == F)



###### Descobrindo links #######

lista.outros.links <- data.frame() ##dataframe principal

for (i in 1:nrow(lista.datasets)) {
  cat(".", i)
  
  temp <-
    fromJSON(readLines(
      paste(
        "http://dadosabertos.bcb.gov.br/api/action/package_show?id=",
        lista.datasets$dataset[i],
        sep = ""
      )
    )) ##recupera informações sobre o dataset
  
  
  
  
  for (x in 1:length(temp$result$resources)) {
    t <- data.frame(
      title = temp$result$title[x],
      dataset = lista.datasets$dataset[i],
      nome = temp$result$resources[[x]]$name,
      formato = temp$result$resources[[x]]$format,
      url = temp$result$resources[[x]]$url,
      
      stringsAsFactors = FALSE
    ) ##gera um dataframe com os links
    
    
    lista.outros.links <-
      bind_rows(lista.outros.links, t) #coloca os dados do dataset no dataframe principal
    
  }
}

##### Remove links inúteis #####

lista.outros.links <-
  filter(
    lista.outros.links,
    lista.outros.links$nome != 'API - Documentação Swagger' &
      lista.outros.links$nome != 'API - Navegador de Dados' &
      lista.outros.links$nome != 'API - Endpoint OData' &
      lista.outros.links$nome != 'Documentação'  &
      lista.outros.links$formato != 'HTML'
  )


##### Altera a url para odata #####

for (i in 1:nrow(lista.outros.links)) {
  if (lista.outros.links$url[i] %like% "olinda.bcb.gov.br/olinda/servico" &
      lista.outros.links$url %like%  "aplicacao#!") {
    lista.outros.links$url <-
      str_replace(lista.outros.links$url, "aplicacao#!", "odata")
  }
}

##### Dados cadastrais de entidades autorizadas #####




data <- format(Sys.Date(), "%m-%d-%Y")

source("entidades_autorizadas.R")




#### Balancetes ####

#### Download Informações cadastrais de instituições ######

download.file("https://www3.bcb.gov.br/informes/rest/cadastros",
              "cadastroGeral.json")



#####Configura o código do conglomerado para o formato necessário #####

conglomerado <-
  fromJSON(readLines(
    "https://www3.bcb.gov.br/informes/rest/cadastros/conglomerado"
  ))

conglomerados <- data.frame()
for (i in 1:length(conglomerado)) {
  conglomerados  <- bind_rows(conglomerados,
                              data.frame(
                                cnpj = paste('C', str_pad(
                                  as.character(cadastro[[i]]$codigo), 7, "left", '0'
                                ), sep = ""),
                                nome = cadastro[[i]]$nome
                                ,
                                stringsAsFactors = F
                              ))
}




source("ifs_balancetes.R")



##### Agências de instituições supervisionadas pelo Bacen  #####



