#### library ��ġ ####
library(tidyr)
library(reshape2)
library(dplyr)
library(stringr)



#### ȣ�⺰�� ������ ������ ####
# ���� : DN8
# ���� : ICT

# ��� ����
setwd("D:/workspace/DN8/ICT/ICT_DVRS_MAIN2_201906")
dir <- c("D:/workspace/DN8/ICT/ICT_DVRS_MAIN2_201906")

file_list <- list.files(dir)
file_cnt <- length(file_list)

#ȣ�� �� temp table ����
data_ICT <- data.frame(matrix(nrow=0, ncol=2))
meta_ICT <- data.frame(matrix(nrow=0, ncol=2))
data1 <- data.frame(matrix(nrow=0, ncol=2))


# data ������
for(i in 1:file_cnt){
  
  #raw data
  temp <- read.table(file_list[i], sep=",", header=FALSE, skip=6,
                     fill=TRUE, stringsAsFactors = FALSE)
  temp$filename <- file_list[i]
  
  data_ICT <- rbind(data_ICT, temp)
  
  
  #meta data
  tmp <- read.csv(file_list[i], header=FALSE, skip=2, nrows=7,
                  stringsAsFactors = FALSE)
  tmp$filename <- file_list[i]
  tmp$V1 <- gsub(" ", "", tmp$V1)
  tmp <- separate(tmp, V1, into=c("v1", "v2"), sep=":")
  tmp$v1 <- gsub("!","", tmp$v1)
  tmp <- dcast(tmp, filename ~ v1, value.var="v2")
  
  meta_ICT <- rbind(meta_ICT, tmp)
  
  #w
  tb <- merge(temp, tmp)
  data1 <- rbind(data1, tb)
  
  print(i)
  
}



data1 <- data1[,-c(16:17)]

# csv ���Ϸ� �����س���
write.csv(data1, "D:/workspace/DN8/dataset/ICT_DN8_ASM_201906.csv")


#### ���̺� ���� ####
# column ���� �޶� �ΰ��� ����
ICT_data01 <- rbind(data2, data3, data3.2, data5)
ICT_data02 <- rbind(data1, data4)

# ������ ����
#  L 20���� ���
colnames(data5) <- c("filename", "StepNum", "PartName", "Actual_V", "Stand_V", "HLim", "LLim", 
                     "Mode", "Type", "Hi_P", "Lo_P", "Skip", "Meas_V", "Dev", "Result", 
                     "BARCODE", "Board_No", "Board_Result", "CurMultipleModel", "DATE")

#  L 17���� ���
colnames(data4) <- c("filename", "StepNum", "PartName", "Actual_V", "Stand_V", "HLim", "LLim", 
                     "Type", "Hi_P", "Lo_P", "Meas_V", "Result",
                     "BARCODE", "Board_No", "Board_Result", "CurMultipleModel", "DATE")


# csv ����
write.csv(ICT_data01, "D:/workspace/DN8/dataset/raw_ICT_DN8_01_201906.csv", row.names = FALSE)
write.csv(ICT_data02, "D:/workspace/DN8/dataset/raw_ICT_DN8_02_201906.csv", row.names = FALSE)

# ������ �ҷ�����
#ICT_data01 <- read.csv("D:/workspace/DN8/dataset/raw_ICT_DN8_01_201906.csv")
#ICT_data02 <- read.csv("D:/workspace/DN8/dataset/raw_ICT_DN8_02_201906.csv")


# ������ ������ ������ ���� ��ġ��
ICT_data01 <- ICT_data01[,-c(8,9,12)]
ICT_data01 <- ICT_data01[,-c(11)]
ICT_data02 <- ICT_data02[,-c(8)]
ICT_data <- rbind(ICT_data01, ICT_data02)




#### data cleaning ####
str(ICT_data)
ICT_data$Board_No <- as.factor(ICT_data$Board_No)

# ������ ���� ����
ICT_data$Meas_V <- substr(ICT_data$Meas_V, 1,9)

# �ӽ� key ���� : �ڵ� + �����ȣ + ��¥
ICT_data$key <- paste(ICT_data$BARCODE, ICT_data$Board_No, ICT_data$DATE, sep="-")

# ��� �� ���� ����
for(i in 1:ncol(ICT_data)){
  ICT_data[,i] <- str_trim(ICT_data[,i], side=c("both", "left", "right"))
}


# �ʿ��� ������ ����
test <- ICT_data[,c("key", "StepNum", "PartName", "Meas_V")]

# �߸� ���� �� ���� 
test <- test %>% filter(PartName != 'PartName')

# �˻� ��ġ 1���� ����
test <- test[order(test$key, test$PartName, desc(test$StepNum)),]

test <- test %>%
  group_by(key, PartName) %>% 
  mutate(numbering = order(key))

test <- test %>% filter(numbering == 1)
test <- test[,-5]


#### �м� dataset ���·� ��ȯ ####
tmp1 <- dcast(test, key ~ PartName, value.var = "Meas_V")

write.csv(tmp1, "S:/������/ICT�����ͼ�.csv")






#### ICT ������Ʈ ��ġ �� ����ġ ���� ####
str(ICT_data)

# �ʿ��� ���� ����
ICT_codeinfo <- ICT_data %>% dplyr::select("PartName", "Actual_V","Stand_V", "HLim", "LLim")

# ���� ����
ICT_codeinfo$PartName <- str_trim(ICT_codeinfo$PartName, side=c("both", "left", "right"))


# ����ġ ����
ICT_codeinfo <- ICT_codeinfo %>% 
  filter(!is.na(ICT_codeinfo$Hi_P))

ICT_codeinfo <- ICT_codeinfo %>% 
  filter(!is.na(ICT_codeinfo$Lo_P))

ICT_codeinfo_uniq <- ICT_codeinfo_uniq %>% 
  filter(!is.na(ICT_codeinfo_uniq$Stand_V))



# ������Ʈ ��ġ ���� ����
ICT_codeinfo <- ICT_codeinfo %>% arrange(PartName)


# �ߺ� �� ����
ICT_codeinfo_uniq  <- ICT_codeinfo %>% 
                        distinct(PartName, Stand_V, Actual_V, HLim, LLim)

ICT_codeinfo_uniq <- ICT_codeinfo_uniq %>% 
                        filter(!is.na(ICT_codeinfo_uniq$PartName))



# ���� ����
ICT_codeinfo_uniq$Stand_V <- as.character(ICT_codeinfo_uniq$Stand_V)
ICT_codeinfo_uniq$Stand_V <- str_sub(ICT_codeinfo_uniq$Stand_V, -8, -3)
ICT_codeinfo_uniq$Stand_V <- as.numeric(ICT_codeinfo_uniq$Stand_V)

ICT_codeinfo_uniq$HLim <- as.character(ICT_codeinfo_uniq$HLim)
ICT_codeinfo_uniq$HLim <- substr(ICT_codeinfo_uniq[,'HLim'], 1, 3)
ICT_codeinfo_uniq$HLim <- as.numeric(ICT_codeinfo_uniq$HLim)
ICT_codeinfo_uniq <- ICT_codeinfo_uniq %>% 
  filter(!is.na(ICT_codeinfo_uniq$HLim))

ICT_codeinfo_uniq$LLim <- as.character(ICT_codeinfo_uniq$LLim)
ICT_codeinfo_uniq$LLim <- substr(ICT_codeinfo_uniq[,'LLim'], 1, 6)
ICT_codeinfo_uniq$LLim <- as.numeric(ICT_codeinfo_uniq$LLim)
ICT_codeinfo_uniq <- ICT_codeinfo_uniq %>% 
  filter(!is.na(ICT_codeinfo_uniq$LLim))


# ���� ���� ���� ����
ICT_codeinfo_uniq$high <- ICT_codeinfo_uniq$Stand_V + 
  ICT_codeinfo_uniq$Stand_V*(ICT_codeinfo_uniq$HLim/100)

ICT_codeinfo_uniq$low <- ICT_codeinfo_uniq$Stand_V - 
  ICT_codeinfo_uniq$Stand_V*(ICT_codeinfo_uniq$LLim/100)


# csv ���� -��-
write.csv(test, "S:/01. ������/DN8/ICT_code_limit3.csv", row.names = FALSE)