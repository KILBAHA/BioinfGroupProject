#Script used to generate the best k9 clusters determined by computer farm

library('flexclust') # handles weighted clustering

setwd("~/Documents/GitHub/BioinfGroupProject/GSEA_rank_cluster")

#set.seed(255)
#read in and format counts (z_scores)
z_scores = read.csv("data_expression_median.txt", sep = "\t", stringsAsFactors = FALSE, header = TRUE)

map = z_scores[,c(1,2)]

inst_names = colnames(z_scores)[3:length(colnames(z_scores))]

z_scores = z_scores[,-2]
z_scores = as.data.frame(t(z_scores), stringsAsFactors = FALSE)
names(z_scores) = map[,1]
z_scores = z_scores[-1,]

z_scores = as.data.frame(apply(z_scores, 2, as.numeric))

name_fix = c()
for(name in inst_names){name_fix = c(name_fix,substr(name,11,nchar(name)-3))}


row.names(z_scores) = name_fix

#read in ranked file, extract names

ranking = read.csv('ranked_gene_list.tsv', sep = "\t")
ranking = ranking$NAME


rz = z_scores[,colnames(z_scores) %in% ranking] #get genes from count included in ranking

rk = ranking[ranking %in% colnames(z_scores)] # get ranked genes included in counts

rz_order = rz[,rk] # order columns by ranking



bestDev = 200

wg <- dnorm(seq(1, ncol(rz_order)), mean = ncol(rz_order)/2, sd = bestDev)

range01 <- function(x){(x-min(x))/(max(x)-min(x))}

wg = range01(wg)


simpleClst = function(seed, k_clust,data, weights =wg){ #run clustering with specified seed and k
  set.seed(seed)
  cls = cclust(data, method = "hardcl", k=k_clust, weights = weights)
  return(cls)
}



bestk9 = simpleClst(9, 9, rz_order)


get_indvs = function(clust, cnum){
  names(which(clusters(clust) == cnum))
}


sizes = c()
for (cnum in 1:9){
  sizes = c(sizes,length(get_indvs(bestk9,cnum)))
}
hist(sizes)

for(cnum in 1:9){
  filenm = paste("k9/","c",cnum,".txt", sep = "")
  antifilenm = paste("k9/","not_c",cnum,".txt", sep="")
  write.table(get_indvs(bestk9,cnum), filenm, sep = "\n", row.names = F, col.names = F, quote = T)
  write.table((rownames(rz_order)[!(rownames(rz_order)%in% get_indvs(bestk9,cnum))]), antifilenm, sep = "\n", row.names = F, col.names = F, quote = T)
}


