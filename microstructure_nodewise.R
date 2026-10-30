suppressPackageStartupMessages({
  library(tidyverse)
  library(parallel)
})

BASE <- "/Volumes/psychology/Ellman_Group/ranesh/Neuro_Projects/HBP/Statistics/Permutation Testing/NDI"
DATA <- file.path(BASE,"final_NDI.csv")

tracts <- c("l_vta_l_hipp","r_vta_r_hipp","l_vta_l_limbic","r_vta_r_limbic")
predictor <- "PNMI"
covars <- c("ICV","mom_education")
nperm <- 1000
pthr <- .05
cores <- max(1,detectCores()-1)
set.seed(123)

df <- read_csv(DATA,show_col_types=FALSE)

node_stats <- function(d,nodes){
  map_dfr(seq_along(nodes),\(i){
    m <- lm(reformulate(c(predictor,covars),nodes[i]),d)
    x <- coef(summary(m))[predictor,]
    tibble(Node=i-1,Estimate=x["Estimate"],SE=x["Std. Error"],
           t=x["t value"],df=df.residual(m),p=x["Pr(>|t|)"],N=nobs(m))
  })
}

clusters <- function(p){
  x <- which(!is.na(p) & p<pthr)
  if(!length(x)) return(list())
  split(x,cumsum(c(1,diff(x)>1)))
}

max_cluster <- function(p){
  x <- clusters(p)
  if(length(x)) max(lengths(x)) else 0
}

results <- list()

for(tr in tracts){
  nodes <- paste0(tr,"_Node",0:99,"_NDI")
  req <- c("Subject",predictor,covars,nodes)
  miss <- setdiff(req,names(df))
  if(length(miss)) stop("Missing: ",paste(miss,collapse=", "))
  
  d <- df %>% select(all_of(req)) %>% drop_na()
  obs <- node_stats(d,nodes)
  cl <- clusters(obs$p)
  big <- if(length(cl)) cl[[which.max(lengths(cl))]] else integer()
  obs_size <- length(big)
  
  perm_max <- unlist(mclapply(seq_len(nperm),\(i){
    dp <- d
    dp[[predictor]] <- sample(dp[[predictor]])
    max_cluster(node_stats(dp,nodes)$p)
  },mc.cores=cores))
  
  threshold <- unname(quantile(perm_max,.95,type=1))
  cluster_p <- (1+sum(perm_max>=obs_size))/(nperm+1)
  
  out <- file.path(BASE,tr)
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  
  obs <- obs %>% mutate(Tract=tr,Predictor=predictor,NodeColumn=nodes,.before=1)
  write_csv(obs,file.path(out,"Nodewise_PNMI.csv"))
  write.table(obs$t,file.path(out,"TValues_PNMI.txt"),row.names=FALSE,col.names=FALSE,quote=FALSE)
  write.table(obs$p,file.path(out,"PValues_PNMI.txt"),row.names=FALSE,col.names=FALSE,quote=FALSE)
  write_csv(tibble(Permutation=1:nperm,MaxClusterSize=perm_max),
            file.path(out,"Permutation_MaxClusterSizes.csv"))
  
  results[[tr]] <- tibble(
    Tract=tr,N=nrow(d),Predictor="PNMI",Outcome="NDI",
    MaxClusterSize=obs_size,
    RequiredClusterSize=threshold,
    ClusterP=cluster_p,
    Pass=obs_size>threshold,
    Direction=if(length(big)) ifelse(mean(obs$t[big])>0,"Positive","Negative") else NA,
    MeanEstimate=if(length(big)) mean(obs$Estimate[big]) else NA,
    MeanT=if(length(big)) mean(obs$t[big]) else NA,
    StartNode=if(length(big)) min(obs$Node[big]) else NA,
    EndNode=if(length(big)) max(obs$Node[big]) else NA
  )
  
  write_csv(results[[tr]],file.path(out,"PNMI_summary.csv"))
}

write_csv(bind_rows(results),file.path(BASE,"NDI_PNMI_All_Tracts_Summary.csv"))
