library(COVID19)
library(tidyverse)
library(patchwork)

##### Get raw data up to the minute from COVID19 package ####
rawdata <- covid19(c("Cambodia","Vietnam","Thailand","China"), level = 1)
rawdata

##### Line plot of cases for top panel #####
require(scales) #For scaling axes
(case.conf <- ggplot(rawdata, aes(x = date, y = confirmed, group=administrative_area_level_1, color=administrative_area_level_1)))
cases <- case.conf + geom_line(aes(linetype=administrative_area_level_1), size=1, alpha=0.5) + 
  labs(x = NULL, y = "Confirmed COVID-19 cases") + 
  theme_classic() +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y")+
  scale_y_continuous(trans='log10', labels=comma) +
  scale_linetype_manual(values=c("dotted","solid","longdash","twodash"))+
  scale_color_manual(name="Country",
                     values=c("red","green","blue","orange")) +
  theme(axis.text.x=element_blank()) +
  theme(legend.position = "none")
cases

##### Identical plot for stringency score #####
(policy.blank <- ggplot(rawdata, aes(x = date, y = stringency_index, group=id)))
policy<-policy.blank+geom_line(aes(linetype=administrative_area_level_1, color=administrative_area_level_1), size=1, alpha=0.5) + 
  labs(x = NULL, y = "Stringency Index") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y")+
  theme_classic() + 
  scale_linetype_manual(name="Country",
                        values=c("dotted","solid","longdash","twodash")) +
  scale_color_manual(name="Country",
                     values=c("red","green","blue","orange")) +
  labs(color  = "Country", linetype = "Country") + 
  theme(legend.position = "bottom", legend.background = element_rect(size=0.5, linetype="solid", 
                                                                     colour ="black")) + 
  theme(axis.text.x = element_text(angle = 50, vjust = 1, hjust = 1, size = 10))

policy

##### Multi-plotting with simple patchwork grammar #####
cases / policy

##### Saving to desktop at default size of graphics device #####
#ggsave("COVID_plot.pdf", width = 190, height = 150, units = "mm", path="outputs")

##### Generate citations, customized based on the contents of the data selected ########
s <- covid19cite(rawdata)