# COVID-food-policy

A simple script to compare COVID cases and stringency of policy response over time, using the wonderful [COVID19 R package](https://cran.r-project.org/web/packages/COVID19/index.html). The aggregated data is provided by the [COVID-19 data hub](https://covid19datahub.io/), undertaking the ambitious work of combining all best available datasets globally.

This script is very basic, producing a 2-panel graph demonstrating covariance in cumulative number of cases from aggregated national reporting, and policy stringency index developed and maintained by the [Oxford COVID-19 Government Response Tracker, Blavatnik School of Government](https://doi.org/10.1038/s41562-021-01079-). This gives a quick way to map a complex, aggregate level of policy response to the pandemic.

First, we load the required packages:

```{r}
library(COVID19) #Package that does most of the work
library(tidyverse) #Data reading and manipulation
library(patchwork) #To stitch the two panels together
```

It is possible to set a date range for our graph. By declining to set a range, the package will default to fetch up-to-date data from the source databases. This means that each time you run the script it will give you the most recently reported data.

I am running the script on a subset of countries that I want to compare, at national level (=1).

```{r}
##### Get raw data up to the minute from COVID19 package ####
rawdata <- covid19(c("Cambodia","Vietnam","Thailand","China"), level = 1)
```

Now we'll run the script to generate the top panel. This will contain the cumulative case numbers. I'll remove the x axis labels because that is already included in the bottom panel. Other packages can autoalign axes and force common labels, but for this simple exercise with consistent axes that is not necessary.

```{r}
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
```

Panel 2 will contain the stringency index for measuring COVID policy application. I parameterize them the same way to match colours and dot types.

```{r}
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
  theme(legend.position = "bottom", legend.background = element_rect(size=0.5, linetype="solid",colour ="black")) + 
  theme(axis.text.x = element_text(angle = 50, vjust = 1, hjust = 1, size = 10))

policy
```

Putting the plots together using patchwork is dead easy (a big advantage with complex layouts...)

```{r}
##### Multi-plotting with simple patchwork grammar #####
cases / policy
```

Finally, we want to know what sources were used for our graphs to make them replicable and publication ready. Luckily for us, the COVID19 package has a function that will parse the data we downloaded and use it to generate citations.

```{r}
##### Generate citations, customized based on the contents of the data selected ########
s <- covid19cite(rawdata)
```
