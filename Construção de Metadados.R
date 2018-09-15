library(rjson)
library(dplyr)
library(stringr)
library(reshape2)


lista.datasets <-
  as.data.frame(fromJSON(
    readLines("http://dadosabertos.bcb.gov.br/api/action/package_list")
  )$result, stringsAsFactors = F)
names(lista.datasets) <- "dataset"

datasets <- data.frame()

for (i in 1:nrow(lista.datasets)) {
  
  info <-
    fromJSON(readLines(
      paste(
        "http://dadosabertos.bcb.gov.br/api/action/package_show?id=",
        lista.datasets$dataset[i],
        sep = ""
      )
    ))$result
  resources <- info$resources
  links = data.frame()
  
  for (x in 1:length(info$resources)) {
    nomes <-
      distinct(as.data.frame(names(resources[[x]]), stringsAsFactors = F))[, 1]
    
    
    temp <-
      data.frame(
        matrix(
          as.character(resources[[x]]),
          nrow = 1,
          byrow = T
        ) ,
        stringsAsFactors = FALSE,
        check.rows = T,
        check.names = T
      )
    names(temp) <- nomes
    links <- bind_rows(links, temp)
    
  }
  
  
  dataset <- data.frame(
    dataset = info$title,
    id = info$id,
    dono = info$maintainer,
    dono_email = if (is.null(info$maintainer_email)) {
      "N/A"
    } else {
      info$maintainer_email
    },
    autor = if (is.null(info$author)) {
      "N/A"
    } else {
      info$author
    },
    data_hora_criacao = if (is.null(info$metadata_created)) {
      "N/A"
    } else {
      info$metadata_created
    } ,
    data_hora_atualizacao = if (is.null(info$metadata_modified)) {
      "N/A"
    } else {
      info$metadata_modified
    } ,
    documentacao = if (is.null(info$documentacao)) {
      "N/A"
    } else {
      info$documentacao
    },
    codigo_sgs = if (is.null(info$codigo_sgs)) {
      "N/A"
    } else {
      info$codigo_sgs
    } ,
    status = if (is.null(info$state)) {
      "N/A"
    } else {
      info$state
    } ,
    data_inicial = if (is.null(info$inicio_periodo)) {
      "N/A"
    } else {
      info$inicio_periodo
    } ,
    data_final = if (is.null(info$fim_periodo)) {
      "N/A"
    } else {
      info$fim_periodo
    },
    unidade_medida = if (is.null(info$unidade_medida)) {
      "N/A"
    } else {
      info$unidade_medida
    },
    qtd_links = if (is.null(info$num_resources)) {
      "N/A"
    } else {
      info$num_resources
    },
    periodicidade = if (is.null(info$periodicidade)) {
      "N/A"
    } else {
      info$periodicidade
    },
    tipo_serie = if (is.null(info$tipo_serie)) {
      "N/A"
    } else {
      info$tipo_serie
    },
    url = if (is.null(info$url)) {
      "N/A"
    } else {
      info$url
    },
    descricao = t(data.frame(if (is.null(links$description)) {
      "N/A"
    } else {
      links$description
    })),
    formato = t(data.frame(if (is.null(links$format)) {
      "N/A"
    } else {
      links$format
    })),
    link = t(data.frame(if (is.null(links$url)) {
      "N/A"
    } else {
      links$url
    })),
    nome_link = t(data.frame(if (is.null(links$name)) {
      "N/A"
    } else {
      links$name
    })),
    link_type = t(data.frame(if (is.null(links$resource_type)) {
      "N/A"
    } else {
      links$resource_type
    })),
    stringsAsFactors = F,
    check.rows =  F
    ,
    row.names = ""
  )
  datasets <- bind_rows(datasets, dataset)
}

rm(dataset, info, resources, nomes, x, i, temp, links, lista.datasets) ##removendo variÃ¡veis que nÃ£o serÃ£o utilizadas daqui pra frente


lista.dataset <-
  datasets[, 1:17]  ##dataset com informaÃ§Ãµes gerais dos datasets

setwd("E:/Pós Graduação/Projeto Aplicado/Scraping")
saida <- toJSON(lista.dataset)
write.table(saida,"lista_dataset.json")

####### lista com informaÃ§Ãµes dos links disponiveis para cada dataset #######

lista.links <-
  datasets[, c(2, 18:length(datasets))] ##seleciona os campos


lista.links <-
  melt(lista.links, id.var = c("id")) ## transforma as colunas em linhas


lista.links <-
  bind_cols(lista.links, id_link =  str_extract(lista.links$variable, "[0-9]+"))

lista.links$variable <-
  str_remove(lista.links$variable, ".[0-9]+") ##padroniza as variÃ¡veis
lista.links <- reshape(
  lista.links,
  timevar = "variable"
  ,
  idvar = c("id", "id_link")
  ,
  direction = "wide"
) ###separa as variaveis em colunas

names(lista.links) <-
  str_remove_all(names(lista.links), "value.") ##renomeando as colunas

saida <- toJSON(lista.links)
write.table(saida,"lista_links.json")


rm(datasets,lista.dataset)
