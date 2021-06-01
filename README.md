# russ_MA
comparison of nutrient based and conventional food clustering in order to identify changes in food diversity and associations to the microbiome in a ketogenic diet cohort

inside notebook folder:

BLS.* files contain upload of BLS (national nutrient database, foods with respective nutrients) data that was used for generating convetional and nutrient based food clustering;
BLS.betadiv contains the computation of the clusterings (convetional clustering was done by BLS food groups, 
nutrient clustering was done by hierarchical clustering of first three PCs of a PCA of the BLS --> that displays nutrient distribution);
BLS.tanglegram contains tanglegram of both clusterings as comparison

Prodi.* files contain basic analysis of ketogenic diet cohort, macronutrient comparison between regular and keto diet
Prodi.toBLS.DP contains merge of diet protocols of ketogenic diet cohort with full nutrient set of BLS

food_diversity folder:

analysis that was done to compare food diversity measurements between nutrient based and conventional food clustering; 
*animal.plant contains comparison of animal and plant derived foods between keto and regular diet;
*BrayCurtis,*Jaccard,*unifrac show inter-sample diversities between keto and regular diet using convetional and nutrient based food clustering;
*faith shows intra-sample diversities between keto and regular diet using convetional and nutrient based food clustering

rarefied_taxa folder:

fecal samlpes between a regualr and keto diet were associated to convetional and nutrient based food cluster intake;
*corr* files contain correlations between species and genus level taxa and conventional cluster intake (convclust), nutrient cluster intake (nutclust), nutrient intake(nutrient);
*family does the same with family level taxa;
*heatmap generates heatmaps out of the correlation matrices;
BA_phenotypes looks into bile acid distribution of different sterol-to-coprostanol converters;
dysbiosis shows inter-sample diversity of fecal samples;
fat.nutrients correlates dietary fat intake with fats in feces;
*alpha contains correlation between alpha dietary diversity and alpha diversity of fecal bacteria;
*maaslin contains linear regression maaslin analysis

unrarefied tatxa folder:

overall this shows the same as rarefied_taxa but with unrarefied taxa tables;
*heatmap generates heatmaps put of correlation matrices --> genus and phyla taxa with nutrients (*volcano), nutrient clusters (*foods) and conventional clusters (*cluster.taxa)
and with family level (*family)
