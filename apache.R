install.packages(c("ggplot2","quantreg"), repos="http://mirrors.softliste.de/cran/")

require("ggplot2")
require("gridExtra")
library(scales)

df = read.table("other_vhosts_access.2015-07-17.log")
df$date=as.POSIXct(df$V5, format="[%d/%b/%Y:%H:%M:%S")
df$ms = df$V8/1000
df$URL = df$V9

top_3_urls <- head(names(sort(table(df$URL),decreasing=TRUE)),3)

df_filter <- df[df$V9 %in% top_3_urls,]
df_rest <- df[!df$V9 %in% top_3_urls,]

p1 <- ggplot(df_filter, aes(x = df_filter$ms, colour = df_filter$URL)) +
  stat_ecdf() +
  scale_x_log10(limits=c(4,40),breaks=c(seq(4,10), seq(10,20,2), seq(20,40,5)),minor_breaks=NULL,name="ms") +
  scale_y_continuous(labels = percent, breaks = c(0,0.5,0.9,0.95,0.99,1), minor_breaks=seq(0,1,0.1), name="Percentiles") +
  guides(colour = FALSE)

p2 <- ggplot(df_filter, aes(x=df_filter$URL, fill=df_filter$URL)) +
  geom_histogram() +
  scale_y_continuous(name = "Total Requests", labels = comma) +
  scale_x_discrete(name = "URL") +
  guides(fill = FALSE)

p3 <- ggplot(df_filter, aes(x=df_filter$date, fill=df_filter$URL)) +
  stat_bin(binwidth=60) +
  scale_x_datetime(name = "Time") +
  scale_y_continuous(name = "Requests/minute") +
  guides(fill = FALSE)

p4 <- ggplot(df_filter, aes(x = df_filter$date, y = df_filter$ms)) +
  stat_bin2d(bins=200) +
  scale_x_datetime(name = "Time") +
  scale_y_log10(name = "ms", limits = c(1,1000)) +
  scale_fill_gradient(low="#00bae5", high="#fa5c19", name="Request count") +
  theme(legend.position = "bottom")

svg("apache.svg", width=10, height=10)
grid.arrange(arrangeGrob(p1, p2, ncol=2), p3, p4, ncol = 1)
dev.off()
