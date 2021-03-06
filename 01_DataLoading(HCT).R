#### library 설치 ####
library(dplyr)
library(reshape2)


#### 호기별로 데이터 모으기 ####
# 차종 : DN8
# 공정 : HCT

# 경로 지정
setwd("D:/workspace/DN8/HCT/DN8C_ICU")
dir <- c("D:/workspace/DN8/HCT/DN8C_ICU")

file_list <- list.files(dir)
(file_cnt <- length(file_list))


#호기 별 temp table 생성
data_HCT <- data.frame(matrix(nrow=0, ncol=2))
meta_HCT <- data.frame(matrix(nrow=0, ncol=2))
data1 <- data.frame(matrix(nrow=0, ncol=2))



# data 모으기
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


# 데이터 병합
data_HCT <- rbind(data1, data2)

# csv 저장
write.csv(data_HCT, "D:/workspace/DN8/dataset/HCT(DVRS)_raw_201906.csv", row.names=FALSE)


# 변수명 정의
colnames(data_HCT) <- c("filename", "StepNum", "PartName", "Actual_V", "HLim", "LLim", 
                        "Mode", "Type", "Hi_P", "Lo_P", "Meas_V", "Result",
                        "BARCODE", "Board_No", "Board_Result", "CurMultipleModel", "DATE")



# 날짜 변수 추가
data_HCT$DATE <- substr(data_HCT$DATE, 1, 8)

# 임시 키 정의 : 바코드 + 보드번호 + 날짜
data_HCT$key <- paste(data_HCT$BARCODE, data_HCT$Board_No, data_HCT$DATE, sep="-")


#### 분석 dataset 형태로 변환 ####
# 필요한 데이터만 추출
test <- data_HCT %>% select("key", "StepNum", "PartName", "Meas_V")

test <- test[order(test$key, test$PartName, desc(test$StepNum)),]
test <- test[,-5]


# key 기준 으로 변환
tmp <- dcast(test2, key ~ PartName, value.var = "Meas_V")


# csv 저장 -끝-
write.csv(tmp, "D:/workspace/DN8/dataset/HCT(DVRS)_dataset_201906.csv", row.names=FALSE)