"
Matrix utilities (distmat, overlap, max_similarity)
"
require(tidyverse)

read_distmat = function(directory, species, suffix) {
  fn = paste0(directory, '/', species, suffix)
  distmat = read.delim(fn, '\t', header=T, row.names=1, stringsAsFactors=F, check.names = F)
  return(distmat)
}

distmat_nonfinite_to_NA = function(distmat) {
  "
  Function takes distance matrix as data frame as input
  transforms non-finite values to NA, 
  returns distance matrix as data frame.
  "
  col_names <- colnames(distmat)
  row_names <- rownames(distmat)
  distmat <- do.call(data.frame, lapply(distmat, function(x) replace(x, !is.finite(x), NA)))
  colnames(distmat) <- col_names
  rownames(distmat) <- row_names
  return(distmat)
}

distmat_filter_NA = function(distmat, output_dropped_names=FALSE, quiet=FALSE) {
  "
  Function takes distance matrix as data frame as input
  and cleans all NA.Rows/Cols containing NA are removed 
  iteratively, beginning with the highest sum of NA.
  Returns distance matrix as data frame 

  or if output_dropped_names == TRUE:
  Returns list of 2 items:
    distmat
    dropped_names as char vector
  "
  require(tidyverse)
  
  # get pre-cleanup count
  distmat.sample_count <- ncol(distmat)
  
  # get samples with NaN and Inf
  distmat.NaN_count <- colSums(!is.finite(as.matrix(distmat)))
  distmat.many_NaN_idx <- distmat.NaN_count > (
    median(distmat.NaN_count) + sd(distmat.NaN_count))
  if (!quiet) print(paste("Many [NaN/Inf]:", names(distmat)[distmat.many_NaN_idx]))
  
  # drop sample with max NaN/Inf until all finite
  distmat.samples_dropped = c()
  while(sum(colSums(!is.finite(as.matrix(distmat)))) > 1) {
    distmat.has_most_NaN_idx <- which.max(colSums(!is.finite(as.matrix(distmat))))
    distmat.samples_dropped <- c(distmat.samples_dropped, 
                                 names(distmat)[distmat.has_most_NaN_idx])
    distmat <- distmat[-distmat.has_most_NaN_idx,
                       -distmat.has_most_NaN_idx]
  }
  
  if (output_dropped_names == TRUE) {
    out <- list("distmat" = as.data.frame(distmat), 
                "dropped_names" = distmat.samples_dropped) 
  } else {
    out <- as.data.frame(distmat)
  }

  # report post-cleanup count
  if (!quiet) {
    print(paste("Objects [Total]:", ncol(distmat)))
    print(paste("Objects [Dropped]:", distmat.sample_count-ncol(distmat)))
    print(paste("Names [Dropped]:", distmat.samples_dropped))
  }
  return(out)
}

distmat_rm_lower_tri = function(distmat, rm_diag=FALSE) {
  "
  Function takes distance matrix as data frame as input
  and returns distance matrix as data frame without lower triangle.
  "  
  if (rm_diag == TRUE) {
    distmat[lower.tri(distmat, diag = TRUE)] <- NA
  } else {
    distmat[lower.tri(distmat, diag = FALSE)] <- NA
  }
  return(distmat)
}

distmat_rm_upper_tri = function(distmat, rm_diag=FALSE) {
  "
  Function takes distance matrix as data frame as input
  and returns distance matrix as data frame without upper triangle.
  "  
  if (rm_diag == TRUE) {
    distmat[upper.tri(distmat, diag = TRUE)] <- NA
  } else {
    distmat[upper.tri(distmat, diag = FALSE)] <- NA
  }
  return(distmat)
}

distmat_add_lower_tri = function(distmat) {
  "
  Function takes distance matrix as data frame without lower tri as input
  and returns full distance matrix as data frame.
  "  
  distmat[lower.tri(distmat)] <- t(distmat)[lower.tri(distmat)]
  return(distmat)
}

distmat_add_upper_tri = function(distmat) {
  "
  Function takes distance matrix as data frame without lower tri as input
  and returns full distance matrix as data frame.
  "  
  distmat[upper.tri(distmat)] <- t(distmat)[upper.tri(distmat)]
  return(distmat)
}

distmat_to_long = function(distmat, value_name, rm_diag = TRUE) {
  "
  Function takes distance matrix as data frame as input
  and returns a data frame in long format,
  containing all values from the distance matrix:
  
  Requires: 
  At least lower triangle of distance matrix,
  modify_distmat script for distance matrix formatting.
  
  -- Output Format
  row col distance
  A B 2.5
  "
  require(tidyverse)
  distmat <- distmat_rm_upper_tri(distmat, rm_diag = rm_diag) %>% 
    rownames_to_column('row')
  distmat <- distmat %>% 
    gather_(key_col = 'col', 
          value_col = value_name,
          gather_cols = names(distmat)[!grepl(names(distmat), pattern = 'row')],
          na.rm = T)
  return(distmat)
}

drop_columns <- function(distmat, pattern_matching_column) {
  column_pattern <- paste0(pattern_matching_column, collapse = '|')
  irrelevant_columns.idx <- grepl(column_pattern, names(distmat))
  print(paste0("Filtering ", sum(irrelevant_columns.idx)," Columns Matching: ", column_pattern))
  return(distmat[!irrelevant_columns.idx, !irrelevant_columns.idx])
}

get_merged_distmats = function(directory, species) {
  distmat = read_distmat(directory, species, '.fraction.txt')
  overlap = read_distmat(directory, species, '.overlap.txt')
  
  # tag nan, inf as NA
  distmat = distmat_nonfinite_to_NA(distmat)
  overlap = distmat_nonfinite_to_NA(overlap)
  
  # # drop NA
  # distmat.clean = distmat_filter_NA(distmat, output_dropped_names=F, quiet=T)
  # overlap.clean = distmat_filter_NA(overlap, output_dropped_names=F, quiet=T)
  
  # wide to long
  distmat.long = distmat_to_long(distmat, value_name='distance', rm_diag=T)
  overlap.long = distmat_to_long(overlap, value_name='overlap', rm_diag=T)
  
  # merge distance, overlap, metadata
  #  - filter own .dom comparisons
  #  - filter self comparisons (rm_diag)
  
  if (nrow(distmat.long) & nrow(overlap.long)) {
    merged_distmat_overlap <- distmat.long %>% 
      left_join(., overlap.long, by = c('row','col')) %>% 
      mutate(species = species,
             available = TRUE) %>% 
      filter(row != col) %>% 
      filter(paste0(row, '.dom') != col, 
             paste0(col, '.dom') != row) %>% 
      filter(! grepl(row, pattern = '.markers$'), 
             ! grepl(col, pattern = '.markers$'))
  } else {
    merged_distmat_overlap <- data.frame(species = species,
                                         available = FALSE,
                                         stringsAsFactors = F)
  }
  return(merged_distmat_overlap)
}