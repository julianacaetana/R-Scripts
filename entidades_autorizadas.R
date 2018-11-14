##### Dados cadastrais de entidades autorizadas #####

for (i in 1:nrow(lista.outros.links)) {
  if (lista.outros.links$nome[i] == "Dados Cadastrais das Entidades Autorizadas") {
    url <-
      paste(
        lista.outros.links$url[i],
        "(dataBase=@dataBase)?@dataBase='",
        data,
        "'&$format=json",
        sep = ""
      )
    download.file(url,
                  paste("Dados Cadastrais das Entidades Autorizadas", data, ".json"))
    entidades <-
      fromJSON(readLines(url))$value
    
    instituicoes <- data.frame()
    for (i in 1:length(entidades)) {
      instituicoes  <-
        bind_rows(
          instituicoes,
          data.frame(
            cnpj = if (!is.null(entidades[[i]]$codigoCNPJ8))
              str_pad(as.character(entidades[[i]]$codigoCNPJ8), 8, "left", '0')
            else
              "N/A",
            nome = entidades[[i]]$nomeEntidadeInteresse,
            cnpj14 = if (is.null(entidades[[i]]$codigoCNPJ14))
              "N/A"
            else
              str_pad(as.character(entidades[[i]]$codigoCNPJ14), 14, "left", '0')
            ,
            stringsAsFactors = F
          )
        )
    }
    
    
  }
  
}
