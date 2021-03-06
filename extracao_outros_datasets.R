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

setwd("D:/P�s Gradua��o/Projeto Aplicado/Scraping/Dados Abertos BC/Outros Datasets")


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
    )) ##recupera informa��es sobre o dataset
  
  
  
  
  for (x in 1:length(temp$result$resources)) {
    t <- data.frame(
      title = temp$result$title[x],
      dataset = lista.datasets$dataset[i],
      nome = temp$result$resources[[x]]$name,
      formato = temp$result$resources[[x]]$format,
      url = temp$result$resources[[x]]$url,
      status = "NO",
      stringsAsFactors = FALSE
    ) ##gera um dataframe com os links
    
    
    lista.outros.links <-
      bind_rows(lista.outros.links, t) #coloca os dados do dataset no dataframe principal
    
  }
}

##### Remove links in�teis #####

lista.outros.links <-
  filter(
    lista.outros.links,
    lista.outros.links$nome != 'API - Documenta��o Swagger' &
      lista.outros.links$nome != 'API - Navegador de Dados' &
      lista.outros.links$nome != 'API - Endpoint OData' &
      lista.outros.links$nome != 'Documenta��o'  &
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

#### Download Informa��es cadastrais de institui��es ######

download.file("https://www3.bcb.gov.br/informes/rest/cadastros",
              "cadastroGeral.json")



#####Configura o c�digo do conglomerado para o formato necess�rio #####

conglomerado <-
  fromJSON(readLines(
    "https://www3.bcb.gov.br/informes/rest/cadastros/conglomerado"
  ))

conglomerados <- data.frame()
for (i in 1:length(conglomerado)) {
  conglomerados  <- bind_rows(conglomerados,
                              data.frame(
                                cnpj = paste('C', str_pad(
                                  as.character(conglomerado[[i]]$codigo), 7, "left", '0'
                                ), sep = ""),
                                nome = conglomerado[[i]]$nome
                                ,
                                stringsAsFactors = F
                              ))
}




source("ifs_balancetes.R")



##### Ag�ncias de institui��es supervisionadas pelo Bacen  #####


for (i in 1:nrow(lista.outros.links)) {
  if (lista.outros.links$nome[i] == "Ag�ncias") {
    
    
    download.file(lista.outros.links$url[i],
                  paste(str_trim(lista.outros.links$nome[i]), ".json",sep = ""))
    lista.outros.links$status[i] <- "OK"
  }
  
}



###### camaras_sistema_liquidacao_titulos_derivativos_cambio) #######
##### Selic, BM&FBOVESPA c�mbio, BM&FBOVESPA ativos, BM&FBOVESPA derivativos, BM&FBOVESPA a��es, CETIP, CIP C3 #####

source("camaras_sistema_liquidacao_titulos_derivativos_cambio.R")


###Correspondentes ####
options(timeout = 999999999)
for (i in 1:nrow(lista.outros.links)) {
  if (lista.outros.links$nome[i] == "Correspondentes") {
   
    
    download.file(lista.outros.links$url[i],
                  paste(str_trim(lista.outros.links$nome[i]), ".json",sep = ""))
    
    lista.outros.links$status[i] <- "OK"
    
  }
  
}
