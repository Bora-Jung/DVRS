#### library 설치 ####
library(dplyr)
library(RODBC)
library(stringr)



#### data input ####
IFT <- read.csv("D:/workspace/DN8/dataset/IFT(DVRS)_dataset_201906.csv", header = T)
ICT <- read.csv("D:/workspace/DN8/dataset/ICT(DVRS)_dataset_201906.csv", header = T)
HCT <- rdad.csv("D:/workspace/DN8/dataset/HCT(DVRS)_dataset_201906.csv", header = T)



#### data tran

# 2019/05/01 부터 데이터셋 구성
IFT$date <- as.character(IFT$date)
IFT <- IFT %>% filter(date > '2019/04/30')

ICT$date <- substr(ICT$key, 12, 19)
ICT <- ICT %>% filter(date > '2019/04/30')
IFT <- IFT[,-1]
ICT <- ICT[,-1]


# IFT 모두 결측치인 컬럼 제거 
x <- as.data.frame(colSums(is.na(IFT)))
x$v1 <- row.names(x)
row.names(x) <- c()
colnames(x) <- c("na_sum", "colname")
x2 <- x %>% filter(na_sum == nrow(IFT)) 
x2 <- as.vector(x$colname)
for(i in 1:length(x2)){
  IFT[,x2[i]] <- NULL
}

# ICT 모두 결측치인 컬럼 제거
x <- as.data.frame(colSums(is.na(ICT)))
x$colname <- row.names(x)
row.names(x) <- c()
colnames(x) <- c("na_sum", "colname")
x2 <- x %>% filter(na_sum == 2802)
x2 <- as.vector(x2$colname)
for(i in 1:length(x2)){
  ICT[,x2[i]] <- NULL
}




# 컬럼명 앞에 공정 붙이기
colnames(IFT) <- paste("IFT_", colnames(IFT), sep="")
colnames(ICT) <- paste("ICT_", colnames(ICT), sep="")
colnames(HCT) <- paste("HCT_", colnames(tmp), sep="")


# code 불러오기
library(RODBC)
con <- odbcDriverConnect("DSN=mssql; uid=sa; pwd=!Yura@@")

code <- sqlQuery(con, 
"SELECT IFTSN, IFTPCBSN, IFTRESULT, SEQ, SN AS ICTSN, PCBSN AS ICTPCBSN, RESULT AS ICTRESULT 
  FROM (  SELECT SN AS IFTSN, PCBSN AS IFTPCBSN, IFTRESULT, BANSN, SEQ
    FROM (
          ( SELECT SN, PCBSN, 'OK' AS IFTRESULT FROM MCNIFT 
            )UNION ALL ( SELECT SN, PCBSN, 'NG' AS IFTRESULT FROM MCNBAD WHERE PCODE LIKE '%IFT%')
           ) AS m
    JOIN (SELECT WANSN, BANSN, SEQ FROM MATCH_BARCODE) AS b ON m.SN = b. WANSN
      ) AS ift JOIN(
                    ( SELECT SN, PCBSN, 'OK' AS RESULT FROM MCNICT ) UNION ALL 
                    ( SELECT SN, PCBSN, 'NG' AS RESULT FROM MCNBAD WHERE PCODE LIKE '%ICT%')
                    ) AS ict 
  ON ict.SN = ift.BANSN
  ORDER BY ift.IFTSN; 
 ")


colnames(code) <- c("IFT_long", "IFT_Short", "IFT_Result", "SEQ",
                    "ICT_long", "ICT_Short", "ICT_Result")


# code 공백 제거
for(i in 1:ncol(code)){
  code[,i] <- str_trim(code[,i], side=c("both", "left", "right"))}

# code 문자형으로 변환
for(i in 1:7){
  code[,i] <- as.character(code[,i])
}



# 바코드 추출
IFT$IFT_BARCODE <- as.character(IFT$IFT_BARCODE)
IFT$IFT_long <- substr(IFT[,'IFT_BARCODE'], 1, 15)

ICT$ICT_key <- as.character(ICT$ICT_key)
ICT$ICT_Short <- substr(ICT[,'ICT_key'], 1, 8)

HCT$HCT_key <- as.character(HCT$HCT_key)
HCT$ICT_Short <- substr(HCT[,'HCT_key'], 1, 8)



# 공정 별 바코드(ICT_Short) 병합
# IFT + 코드
tmp1 <- merge(IFT, code,
              by = "IFT_long", all.x = TRUE)

# ICT + 코드
tmp2 <- merge(ICT, code,
              by = "ICT_Short", all.x = TRUE)

# HCT + 코드
tmp3 <- merge(HCT, code, 
              by="ICT_Short", all.x = TRUE)

# IFT + ICT
IFT_ICT <- merge(tmp1, tmp2, 
                 by="ICT_Short")

IFT_ICT_HCT <- merge(IFT_ICT, tmp3,
                     by="ICT_Short")



# 결측치 제거
colnames(IFT_ICT_HCT)
sum(is.na(IFT_ICT_HCT$ICT_Short))
IFT_ICT_HCT <- IFT_ICT_HCT %>% filter(!is.na(ICT_key))


# csv 저장
write.csv(IFT_ICT_HCT, "D:/workspace/DN8/dataset/IFT_ICT_HCT_201906.csv", row.names = FALSE)




IFT_ICT_HCT <- read.csv("D:/workspace/DN8/dataset/IFT_ICT_HCT.csv", header=TRUE)
unique(IFT_ICT_HCT$ICT_Short)





#### 코드 중복 제거(unique 값 매핑) ####
data.table(ex1)
ex1$filename <- IFT_DVRS[,'filename']

ex1 <- substr(ex1$filename, 6, 21)
ex1 <- unique(ex1)

ex2 <- IFT_ICU[,c('filename','load')]
ex2 <- filter(ex2, !grepl('Report', filename))
ex2$filename <- substr(ex2$filename, 1, 15)

ex1 <- as.data.frame(ex1)
ex2 <- as.data.frame(ee)

colnames(ex1) <- "barcode"
colnames(ex2) <- "barcode"

IFT_barcode <- rbind(ex1, ex2)
write.csv(IFT_barcode, "S:/정보라/DN8/IFT_barcode.csv")
