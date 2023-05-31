* @ValidationCode : Mjo5NjAwNzE0NzI6Q3AxMjUyOjE2ODQ4NTc0MTEzNDg6SVRTUzotMTotMTo0NTEwOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 23 May 2023 21:26:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 4510
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.BM
PROGRAM JT.ANALYSE
*MODIFICATION HISTORY:
*---------------------------------------------------------------------------------------
*DATE               WHO                       REFERENCE                 DESCRIPTION
*21-04-2023       CONVERSION TOOLS            AUTO R22 CODE CONVERSION   IF STATEMENT MODIFIED,CONVERT into CHANGE,= to EQ,I to I.VAR ,HUSH ON and HUSH OF into CALL HUSHIT(0)and CALL HUSHIT(1)
*21-04-2023       AJITHKUMAR                  MANUAL R22 CODE CONVERSION SPACE ADDED AFTER TO
*----------------------------------------------------------------------------------------


    

    OPEN 'F.SPF' TO F.SPF ELSE CRT 'Unable to open F.SPF file' ; STOP
    OPEN 'F.DATES' TO F3 ELSE CRT 'Unable to open F.DATES file' ; STOP
    OPEN 'F.BATCH' TO F2 ELSE CRT 'Unable to open F.BATCH file' ; STOP
    OPEN 'F.JOB.TIMES' TO F1 ELSE CRT 'Unable to open F.JOB.TIMES file' ; STOP
    READ Y.R.SPF FROM F.SPF, 'SYSTEM' THEN
        RELS = Y.R.SPF<8>
        RELS=FIELD(FIELD(RELS,'.',1),'R',2)
    END
    EXECUTE 'SELECT F.DATES'
    READLIST DATES.LIST ELSE DATES.LIST = ''
    DATE.ID = DATES.LIST<1>
    READ DATES.REC FROM F3,DATE.ID ELSE
        DATES.REC=''
        CRT 'Dates record not found'
    END
    IF NOT(DATES.REC) THEN
READ.DATE:
        CRT 'Input COB Date (Ex: 20110101):';INPUT COB.DATE
        IF LEN(COB.DATE) NE 8 THEN ;*R22 AUTO CODE CONVERSION-START
            CRT 'Invalid Date' ; GOTO READ.DATE:
        END ;*R22 AUTO CODE CONVERSION-END
    END ELSE
        COB.DATE = DATES.REC<3>
    END

    CRT 'Extracting JOB.TIMES for COB.DATE ':COB.DATE
    OUT.FILE='JT.':COB.DATE:'.CSV'
    OPENSEQ OUT.FILE TO F.OUTFILE ELSE CRT 'New file ':OUT.FILE:' Opened'
    CRT 'Selecting BATCH record....'
    CALL HUSHIT(1) ;*R22 AUTO CODE CONVERSION
    EXECUTE 'SSELECT F.BATCH WITH BATCH.STAGE NE "" BY BATCH.STAGE'
    CALL HUSHIT(0) ;*R22 AUTO CODE CONVERSION
    CRT.ARRAY=''
    IF RELS GT 8 THEN
        CRT.ARRAY<-1>="BATCH.STAGE,BATCH,JOB.NAME,START.TIME,END.TIME,ELAPSED.TIME,PROCESSED RECS,THROUGHPUT,COMPLETED RECS,SELECTION.TIME,BULK.NO,TXN.MGMT,WRITE.CACHE,LOCK.COLLISION,TOTAL WRITE,,DET PROCESSED,DET COMPLETED,DET THROUGHPUT,DET BULK.NUMBER,DET SELECT,TYPE OF SELECT, DET SELECT TIME"
    END ELSE
        CRT.ARRAY<-1>="BATCH.STAGE,BATCH,JOB.NAME,START.TIME,END.TIME,ELAPSED.TIME,PROCESSED RECS,THROUGHPUT,COMPLETED RECS,NO OF AGENTS,SELECTION.TIME"
    END
    APPL.ANALYSE='';SYS.ANALYSE='';REP.ANALYSE='';STR.ANALYSE='';ONL.ANALYSE=''
    LOOP
        READNEXT ID ELSE ID=''
    WHILE ID
        READ BATCH.REC FROM F2,ID ELSE
            BATCH.REC=''
        END
        BATCH.STAGE=BATCH.REC<1>
        IF BATCH.STAGE[1,1] EQ 'A' AND NOT(APPL.ANALYSE) THEN ;*R22 AUTO CODE CONVERSION-
            APPL.ANALYSE='1'
            CRT 'Processing APPLICATION Stage....'
        END
        IF BATCH.STAGE[1,1] EQ 'S' AND NOT(SYS.ANALYSE) THEN ;*R22 AUTO CODE CONVERSION-
            SYS.ANALYSE='1'
            CRT 'Processing SYSTEM Stage....'
        END
        IF BATCH.STAGE[1,1] EQ 'R' AND NOT(REP.ANALYSE) THEN
            REP.ANALYSE='1'
            CRT 'Processing REPORTING Stage....'
        END
        IF BATCH.STAGE[1,1] EQ 'D' AND NOT(STR.ANALYSE) THEN
            STR.ANALYSE='1'
            CRT 'Processing START.OF.DAY Stage....'
        END
        IF BATCH.STAGE[1,1] EQ 'O' AND NOT(ONL.ANALYSE) THEN
            ONL.ANALYSE='1'
            CRT 'Processing ONLINE Stage....'
        END
        JOB.LIST=BATCH.REC<6>
        NO.JOBS=DCOUNT(JOB.LIST,@VM)
        ECF.FLAG = ''
        FOR I.VAR = 1 TO NO.JOBS
            JT.ID=ID:"-":JOB.LIST<1,I.VAR> ;*R22 AUTO CODE CONVERSION
            READ JT.REC FROM F1,JT.ID ELSE
                JT.REC=''
            END
            J.DATE=JT.REC<3>

            LOCATE COB.DATE IN J.DATE<1,1> SETTING POS ELSE POS=''
            IF JOB.LIST<1,I.VAR> EQ 'EB.CLEAR.FILES' THEN ;*R22 AUTO CODE CONVERSION
                IF NOT(ECF.FLAG) THEN
                    ECF.FLAG = '1'
                END ELSE
                    POS += 1
                END
            END
            IF POS THEN

                IF JT.REC<5,POS> LT JT.REC<4,POS> THEN
                    ELAPSED.TIME=86400 - JT.REC<4,POS>
                    ELAPSED.TIME+=JT.REC<5,POS>
                END ELSE
                    ELAPSED.TIME=JT.REC<6,POS>
                END
                ELAPSED.TIME=OCONV(ELAPSED.TIME,'MTS')
                START.TIME=JT.REC<4,POS>

                START.TIME=OCONV(START.TIME,'MTS')
                END.TIME=JT.REC<5,POS>
                END.TIME=OCONV(END.TIME,'MTS')

                SELECT.TIME = JT.REC<12,POS>
                SELECT.TIME = OCONV(SELECT.TIME,'MTS')
                IF RELS GT 8 THEN
                    GOSUB R9U
                END ELSE
                    GOSUB R8
                END

*PROCESSED RECORDS

            END
        NEXT I.VAR ;*R22 AUTO CODE CONVERSION-
    REPEAT
    WRITE.FLAG=''
    NO.OF.RECORDS=DCOUNT(CRT.ARRAY,@FM)
    IF NO.OF.RECORDS EQ '1' THEN ;*R22 AUTO CODE CONVERSION-START
        NO.OF.RECORDS=''
    END ;*R22 AUTO CODE CONVERSION-END
    FOR I.VAR = 1 TO NO.OF.RECORDS ;* MANUAL R22 CODE CONVERSION - SPACE ADDED AFTER TO
        WRITESEQ CRT.ARRAY<I.VAR> ON F.OUTFILE ELSE CRT 'Unable to write out'
        WRITE.FLAG='1'
    NEXT I.VAR
    CRT '*******************************************************************'
    IF WRITE.FLAG THEN
        CRT 'Kindly Extract the file JT.':COB.DATE:'.CSV from your RUN directory'
    END ELSE
        CRT 'JOB.TIMES not found'
    END
    CRT '*******************************************************************'
    STOP

R8:
    CURRENT.LINE=BATCH.STAGE:'-':JT.ID:'-':START.TIME:'-':END.TIME:'-':ELAPSED.TIME:'-':JT.REC<7,POS>:'-':JT.REC<8,POS>:'-':JT.REC<9,POS>:'-':JT.REC<11,POS>
    CURRENT.LINE = CURRENT.LINE:'-':SELECT.TIME
    CHANGE '-' TO ',' IN CURRENT.LINE ;*R22 AUTO CODE CONVERSION
    CRT.ARRAY<-1>=CURRENT.LINE
RETURN

R9U:

    PROCESSED= JT.REC<20,POS>
    CHANGE @SM TO @FM IN PROCESSED
    NO.P = DCOUNT(PROCESSED,@FM)
    Y.PROCESSED = ''
    FOR SS = 1 TO NO.P
        Y.PROCESSED+=PROCESSED<SS>
    NEXT SS
    CHANGE @FM TO '*' IN PROCESSED
*COMPLETED RECORDS
    COMPLETED=JT.REC<21,POS>
    CHANGE @SM TO @FM IN COMPLETED
    NO.P = DCOUNT(COMPLETED,@FM)
    Y.COMPLETED = ''
    FOR SS = 1 TO NO.P
        Y.COMPLETED+=COMPLETED<SS>
    NEXT SS
    CHANGE @FM TO '*' IN COMPLETED
*BULK.NUMBER
    BULK.NUMBER=JT.REC<16,POS>
    Y.BULK.NUMBER = BULK.NUMBER<1,1,1>
    CHANGE @SM TO '*' IN BULK.NUMBER
*TYPE OF SELECT
    T.SELECT=JT.REC<17,POS>
    CHANGE @SM TO '*' IN T.SELECT
*SELECTED RECORDS
    SS.SELECT = JT.REC<18,POS>
    CHANGE @SM TO '*' IN SS.SELECT
*SELECT TIME
    S.TIME = JT.REC<19,POS>
    CHANGE @SM TO @FM IN S.TIME
    NO.P = DCOUNT(S.TIME,@FM)
    Y.S.TIME = ''
    FOR SS = 1 TO NO.P
        Y.S.TIME+=S.TIME<SS>
    NEXT SS
    CHANGE @FM TO '*' IN S.TIME
*THROUGHPUT
    THROUGHPUT = JT.REC<8,POS>
    CHANGE @SM TO @FM IN THROUGHPUT
    NO.P = DCOUNT(THROUGHPUT,@FM)
    Y.THROUGHPUT = ''
    FOR SS = 1 TO NO.P
        Y.THROUGHPUT+=THROUGHPUT<SS>
    NEXT SS
    CHANGE @FM TO '*' IN THROUGHPUT
    CURRENT.LINE=BATCH.STAGE:'-':JT.ID:'-':START.TIME:'-':END.TIME:'-':ELAPSED.TIME:'-':Y.PROCESSED:'-':Y.THROUGHPUT:'-':Y.COMPLETED:'-':Y.S.TIME:'-':Y.BULK.NUMBER:'-':JT.REC<22,POS>:'-':JT.REC<23,POS>:'-':JT.REC<24,POS>:'-':JT.REC<25,POS>:'--':PROCESSED:'-':COMPLETED:'-':THROUGHPUT:'-':BULK.NUMBER:'-':SS.SELECT:'-':T.SELECT:'-':S.TIME
    CHANGE '-' TO ',' IN CURRENT.LINE
    CRT.ARRAY<-1>=CURRENT.LINE
RETURN
