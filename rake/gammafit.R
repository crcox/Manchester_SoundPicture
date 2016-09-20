#!/home/chris/lib/R/library/littler/bin/r
.libPaths( c( .libPaths(), "/home/chris/lib/R/library") )

print_stderr <- function(...) {
  sink(file=stderr())
  print(...)
  sink(file=NULL)
}
gamma.methodofmoments <- function(x) {
  shape <- function(x) {
    mean(x)^2/var(x)
  }
  scale <- function(x) {
    var(x)/mean(x)
  }
  rate <- function(x) {
    1/scale(x)
  }
  list(estimate=c(shape=shape(x),rate=rate(x)))
}
gamma.na <- function() {
  list(estimate=c(shape=NA,rate=NA))
}

## configuration for docopt
doc <- "Usage: gammafit [options] <permfile> <meanfile> <statfile>

options:
  -h --help   Show this help text
  --debug     Print extra output [default: FALSE]"

## docopt parsing
opt <- docopt::docopt(doc)
if (opt$debug) {
  print_stderr(opt)
}

p <- read.table(opt$permfile,header=FALSE);
p_ijk <- p[,1:3];
p <- as.matrix(p[,4:ncol(p)]);
names(p_ijk) <- c('i','j','k')

m <- read.table(opt$meanfile, header=FALSE);
m_ijk <- m[,1:3];
m <- as.vector(as.matrix(m[,4]));
names(m_ijk) <- c('i','j','k')

stopifnot(identical(m_ijk,p_ijk))
ijk <- m_ijk
rm(m_ijk, p_ijk)

spath <- tools::file_path_sans_ext(opt$statfile)
sext <- tools::file_ext(opt$statfile)
paramsfile <- sprintf('%s.params.%s',spath,sext);

nvox <- nrow(p);
params <- data.frame(shape=rep(NA,nvox),rate=rep(NA,nvox),shape.mom=rep(NA,nvox),rate.mom=rep(NA,nvox),pval=rep(NA,nvox))
for (i in 1:nvox) {
  if (!any(p[i,]==0)) {
    x <- MASS::fitdistr(p[i,], "gamma")
  } else {
    x <- gamma.na()
  }
  y = gamma.methodofmoments(p[i,])
  params$shape[i] <- x$estimate["shape"]
  params$rate[i] <- x$estimate["rate"]
  params$shape.mom[i] <- y$estimate["shape"]
  params$rate.mom[i] <- y$estimate["rate"]
  if (is.na(x$estimate["shape"])) {
    params$pval[i] <- 1-stats::pgamma(m[i],shape=y$estimate["shape"], rate=y$estimate["rate"])
  } else {
    params$pval[i] <- 1-stats::pgamma(m[i],shape=x$estimate["shape"], rate=x$estimate["rate"])
  }
}

write.table(cbind(ijk,params[,"pval"]),file=opt$statfile,row.names=FALSE,sep=' ');
write.table(cbind(ijk,params),file=paramsfile,row.names=FALSE,sep=' ');
