* @ValidationCode : MjotMjA1ODk0NjU1MDpDcDEyNTI6MTY4MzY5ODQxNzgzODpJVFNTOi0xOi0xOjIyNzM6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 2273
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
PROGRAM AA.COR.DATED.XREF

*-----------------------------------------------------------------------------------
* Modification History:
*
*DATE                 WHO                  REFERENCE                    DESCRIPTION
* 28/03/2023         SURESH        MANUAL R22 CODE CONVERSION     Package Name added APAP.AA
* 28/03/2023       Conversion Tool        AUTO R22 CODE CONVERSION             <> to NE
*-----------------------------------------------------------------------------------
* This program is to set all the AA.PRD.CAT.PRODUCT.XREF files to 20090101 date.
* So that previous DATED contions will be removed and all the product conditions
* defaulty set to 20090101
* Written by: dharibabu@temenos.com
* Modified by: anandhanr@temenos.com
* Client: APAP

    $INSERT I_COMMON
    $INSERT I_EQUATE

* Clear the property conditions and desing records first

    PROPERTY.CLASS = ""
    OPEN "F.AA.PROPERTY.CLASS"  TO PROPERTY.CLASS ELSE
        PRINT "UNABLE TO OPEN THE FILE FBNK.AA.PRD.CAT.DATED.XREF"
    END

    CALL EB.READLIST('SELECT F.AA.PROPERTY.CLASS',PROP.LIST,'',NO.OF.REC,ERR)
    LOOP
        REMOVE PROP.CLASS.ID FROM PROP.LIST SETTING PROP.CLASS.POS
    WHILE PROP.CLASS.ID:PROP.CLASS.POS
        PRD.DES.FILE = 'FBNK.AA.PRD.DES.':PROP.CLASS.ID
        F.PRD.DES.FILE = ''
        OPEN PRD.DES.FILE TO F.PRD.DES.FILE ELSE
            PRINT "UNABLE TO OPEN THE FILE":PRD.DES.FILE
        END

        SEL.CMD = 'SELECT ':PRD.DES.FILE:' WITH @ID UNLIKE ...20090101...'
        CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,ERR)
        LOOP
            REMOVE PRD.DES.ID FROM SEL.LIST SETTING PRD.DES.POS
        WHILE PRD.DES.ID:PRD.DES.POS

            DELETE F.PRD.DES.FILE,PRD.DES.ID
            PRINT 'SYSTEM DELETED THE RECORD ':PRD.DES.ID:'  FROM  ':PRD.DES.FILE
        REPEAT

        PRINT "------------SYSTEM PROCESSED THE FILE:  ":PRD.DES.FILE:"  -----------------"

        PRD.CAT.FILE = 'FBNK.AA.PRD.CAT.':PROP.CLASS.ID
        F.PRD.CAT.FILE = ''

        OPEN PRD.CAT.FILE TO F.PRD.CAT.FILE ELSE
            PRINT "UNABLE TO OPEN THE FILE":PRD.CAT.FILE
        END


        SEL.CMD1 = 'SELECT ':PRD.CAT.FILE:' WITH @ID UNLIKE ...20090101...'
        CALL EB.READLIST(SEL.CMD1,SEL.LIST1,'',NO.OF.REC,ERR)
        LOOP
            REMOVE PRD.CAT.ID FROM SEL.LIST1 SETTING PRD.DES.POS1
        WHILE PRD.CAT.ID:PRD.DES.POS1

            DELETE F.PRD.CAT.FILE,PRD.CAT.ID
            PRINT 'SYSTEM DELETED THE RECORD ':PRD.CAT.ID:'  FROM  ':PRD.CAT.FILE
        REPEAT
        PRINT "------------SYSTEM PROCESSED THE FILE:  ":PRD.CAT.FILE:"  -----------------"
    REPEAT

    PRINT "======================================================"
    PRINT "---- RESET THE XREF FILE OF PRODUCTION CONDITIONS ----"
    PRINT "======================================================"

    PRINT "====================================================="
    PRINT "---RESET THE DES XREF FILE-------"
    PRINT "===================================================="

    OPEN "FBNK.AA.PRD.DES.DATED.XREF" TO PRD.DES.XREF ELSE
        PRINT "UNABLE TO OPEN THE FILE FBNK.AA.PRD.DES.DATED.XREF"
    END

    PRD.DES.REC = ""
    PRD.DES.ID = ""
    CNT1 = 0
    CNT.PRC1 = 0
*TUS START
*  SELECT PRD.DES.XREF
*  LOOP
*    READNEXT PRD.DES.ID ELSE
*      PRD.DES.ID = ""
*    END
*  WHILE PRD.DES.ID
    SEL.STMT = "SELECT PRD.DES.XREF"
    CALL EB.READLIST(SEL.STMT,ID.LIST,'',ID.SELECTED,ERR)
    LOOP
        REMOVE PRD.DES.ID FROM ID.LIST SETTING POS
*     REMOVE PRD.DES.ID FROM  SETTING POS
    WHILE PRD.DES.ID : POS
*TUS END
*    READ PRD.DES.REC FROM PRD.DES.XREF,PRD.DES.ID ELSE ;*Tus Start
        CALL F.READ(FN.DES.XREF,PRD.DES.ID,PRD.DES.REC,PRD.DES.XREF,PRD.DES.REC.ERR)
        IF PRD.DES.REC.ERR THEN  ;* Tus End
            PRINT "UNABLE TO READ THE RECORD ":PRD.DES.ID:" FROM FBNK.AA.PRD.DES.DATED.XREF"
        END
        IF PRD.DES.REC<1> NE "20090101" THEN ;*AUTO R22 CODE CONVERSION
            PRINT "Processing the record :":PRD.DES.ID:   "    Old value is :":PRD.DES.REC<1>:"   New value is :20090101"
            PRD.DES.REC<1> = "20090101"
            WRITE PRD.DES.REC TO PRD.DES.XREF,PRD.DES.ID ON ERROR
                PRINT "UNABLE TO WRITE THE RECORD ":PRD.DES.ID:" FROM FBNK.AA.PRD.DES.DATED.XREF"
            END
            CNT.PRC1 +=1
        END
        CNT1 +=1
    REPEAT

    PRINT "TOTAL DES RECORDS PROCESSED :":CNT1
    PRINT "TOTAL DES RECORDS CORRECTED :":CNT.PRC1


    PRINT "====================================================="
    PRINT "---RESET CAT XREF FILE-------"
    PRINT "===================================================="

    OPEN "FBNK.AA.PRD.CAT.DATED.XREF" TO PRD.CAT.XREF ELSE
        PRINT "UNABLE TO OPEN THE FILE FBNK.AA.PRD.CAT.DATED.XREF"
    END

    PRD.CAT.REC = ""
    PRD.CAT.ID = ""
    CNT = 0
    CNT.PRC = 0
* TUS START
*  SELECT PRD.CAT.XREF
*  LOOP
*    READNEXT PRD.CAT.ID ELSE
*      PRD.CAT.ID = ""
*    END
*  WHILE PRD.CAT.ID
    SEL.STMT = "SELECT PRD.CAT.XREF"
    CALL EB.READLIST(SEL.STMT,ID.LIST,'',ID.SELECTED,ERR)
    LOOP
*   REMOVE PRD.CAT.ID FROM PRD.CAT.XREF SETTING POS
        REMOVE PRD.CAT.ID FROM ID.LIST SETTING POS
    WHILE PRD.CAT.ID : POS
*TUS END

        READ PRD.CAT.REC FROM PRD.CAT.XREF,PRD.CAT.ID ELSE ;*Tus Start
*CALL F.READ(FN.CAT.XREF,PRD.CAT.ID,PRD.CAT.REC,PRD.CAT.XREF,PRD.CAT.REC.ERR)
* IF PRD.CAT.REC.ERR THEN  ;* Tus End
            PRINT "UNABLE TO READ THE RECORD ":PRD.CAT.ID:" FROM FBNK.AA.PRD.CAT.DATED.XREF"
        END
        IF PRD.CAT.REC<1> NE "20090101" THEN ;*AUTO R22 CODE CONVERSION
            PRINT "Processing the record :":PRD.CAT.ID:   "    Old value is :":PRD.CAT.REC<1>:"   New value is :20090101"
            PRD.CAT.REC<1> = "20090101"
            WRITE PRD.CAT.REC TO PRD.CAT.XREF,PRD.CAT.ID ON ERROR
                PRINT "UNABLE TO WRITE THE RECORD ":PRD.CAT.ID:" FROM FBNK.AA.PRD.CAT.DATED.XREF"
            END
            CNT.PRC +=1
        END
        CNT +=1
    REPEAT
    PRINT "TOTAL CAT RECORDS PROCESSED :":CNT
    PRINT "TOTAL CAT RECORDS CORRECTED :":CNT.PRC
END
