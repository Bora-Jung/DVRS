#### library ��ġ ####
library(dplyr)
library(reshape2)


#### ȣ�⺰�� ������ ������ ####
# ���� : DN8
# ���� : HCT

# ��� ����
setwd("D:/workspace/DN8/HCT/DN8C_ICU")
dir <- c("D:/workspace/DN8/HCT/DN8C_ICU")

file_list <- list.files(dir)
(file_cnt <- length(file_list))


#ȣ�� �� temp table ����
data_HCT <- data.frame(matrix(nrow=0, ncol=2))
meta_HCT <- data.frame(matrix(nrow=0, ncol=2))
data1 <- data.frame(matrix(nrow=0, ncol=2))



# data ������
for(i in 1:file_cnt){
  
  # raw data
  temp <- read.table(file_list[i], sep=",", header = FALSE, skip = 10,
                     fill = TRUE, stringsAsFactors = FALSE)
  temp$filename <- file_list[i]
  
  data_HCT <- rbind(data_HCT, temp)
  
  
  # meta data
  tmp <- read.csv(file_list[i], header = FALSE, skip=2, nrows=5,
                  stringsAsFactors = FALSE)
  tmp$filename <- file_list[i]
  tmp$V1 <- gsub(" ", "", tmp$V1)
  tmp <- separate(tmp, V1, into=c("v1", "v2"), sep=":")
  tmp$v1 <- gsub("!","", tmp$v1)
  tmp <- dcast(tmp, filename ~ v1, value.var="v2")
  
  meta_HCT <- rbind(meta_HCT, tmp)
  
  # all data
  tb <- merge(temp, tmp)
  data1 <- rbind(data1, tb)
  
  print(i)
  
}


# ������ ����
data_HCT <- rbind(data1, data2)

# csv ����
write.csv(data_HCT, "D:/workspace/DN8/dataset/HCT(DVRS)_raw_201906.csv", row.names=FALSE)


# ������ ����
colnames(data_HCT) <- c("filename", "StepNum", "PartName", "Actual_V", "HLim", "LLim", 
                        "Mode", "Type", "Hi_P", "Lo_P", "Meas_V", "Result",
                        "BARCODE", "Board_No", "Board_Result", "CurMultipleModel", "DATE")



# ��¥ ���� �߰�
data_HCT$DATE <- substr(data_HCT$DATE, 1, 8)

# �ӽ� Ű ���� : ���ڵ� + �����ȣ + ��¥
data_HCT$key <- paste(data_HCT$BARCODE, data_HCT$Board_No, data_HCT$DATE, sep="-")


#### �м� dataset ���·� ��ȯ ####
# �ʿ��� �����͸� ����
test <- data_HCT %>% select("key", "StepNum", "PartName", "Meas_V")

test <- test[order(test$key, test$PartName, desc(test$StepNum)),]
test <- test[,-5]


# key ���� ���� ��ȯ
tmp <- dcast(test2, key ~ PartName, value.var = "Meas_V")


# csv ���� -��-
write.csv(tmp, "D:/workspace/DN8/dataset/HCT(DVRS)_dataset_201906.csv", row.names=FALSE)