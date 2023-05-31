* @ValidationCode : MjoxMTE1MDgxNjUyOkNwMTI1MjoxNjg1NTM0MDQ4MTY1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:24:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE TAM.UPDATE.HOST.DETAILS
      
*-----------------------------------------------------------------------------------
* Modification History:
*DATE                 WHO                  REFERENCE                    DESCRIPTION
*29/03/2023         CONVERSION TOOL     AUTO R22 CODE CONVERSION          VM TO @VM,FM TO @FM
*29/03/2023         SURESH              MANUAL R22 CODE CONVERSION        CALL rtn format modified
*-----------------------------------------------------------------------------------
*------------------------------------------------------------------------------
*Company Name      : APAP Bank
*Developed By      : Shankar Raju
*Program Name      : TAM.UPDATE.HOST.DETAILS
*Date              : 05/10/2010
*-----------------------------------------------------------------------------------------------------------------
*Description       : This is a T24 routine which retrieves the information(IP AND HOST NAME) from the local table
*                    TAM.HOST.DETAILS.TRACE and stores it in the local fields HOST.NAME & IP.ADDRESS
*Linked With       : SYSTEM record of the VERSION.CONTROL
*Linked File       : TAM.HOST.DETAILS.TRACE In Read mode
*------------------------------------------------------------------------------------------------------------------
*Modification History:
*
*    DATE               ODR REFERENCE                 WHO              DESCRIPTION
*    ----               -------------                 ---              -----------
* 05.10.2010           HOST DETAILS TRACE-B.149  Shankar Raju         Host name & Details trace
* 28.12.2011           ODR-2010-03-0116          Shankar Raju     Added for SegN4 - Called a routine
* 10.01.2012             TUT1276149              Shankar Raju     Read on Standard Selection is replaced with a call to API [GET.STANDARD.SELECTION.DETS]
*------------------------------------------------------------------------------------------------------------------
* Input/Output:
* -------------
* In  : N/A
* Out : N/A
*------------------------------------------------------------------------------------------------------------------
* Dependencies:
* -------------
* Calls     : N/A
* Called By : N/A
*------------------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.TAM.HOST.DETAILS.TRACE
    $INSERT I_F.TAM.HOST.DETAILS.TRACE.ARCIB
    $INSERT I_F.STANDARD.SELECTION
    $INSERT I_EB.EXTERNAL.COMMON
    $INSERT I_System
    $INSERT I_F.OFS.SOURCE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.VERSION
    $USING APAP.REDOAPAP
*

 
    TAM.V.OVERRIDES = OFS$OVERRIDES
    TAM.V.OVERRIDES = FIELD(TAM.V.OVERRIDES,@FM,2) ;*AUTO R22 CODE CONVERSION
    TAM.V.OVERRIDES = CHANGE(TAM.V.OVERRIDES,'NO','')
    TAM.V.OVERRIDES = CHANGE(TAM.V.OVERRIDES,@VM,'') ;*AUTO R22 CODE CONVERSION

* To restrict Input routine from triggering while accepting Overrides


    IF  NOT(OFS.VAL.ONLY) THEN

        IF TAM.V.OVERRIDES EQ '' THEN

            GOSUB INITIALISE
            GOSUB PROCESS
* Added for SegN4 - ODR-2010-03-0116 - Shankar Raju
            GOSUB CALL.TRACE.LOG
        END ELSE
            IF R.VERSION(EB.VER.NO.OF.AUTH) EQ 0 THEN
                GOSUB CALL.TRACE.LOG
            END
        END

    END
*
RETURN

*-----------
INITIALISE:
*-----------

    Y.APPL = APPLICATION

    FN.TAM.HOST.DETAILS.TRACE = 'F.TAM.HOST.DETAILS.TRACE'
    F.TAM.HOST.DETAILS.TRACE = ''
    CALL OPF(FN.TAM.HOST.DETAILS.TRACE,F.TAM.HOST.DETAILS.TRACE)

    FN.TAM.HOST.DETAILS.TRACE.ARCIB = 'F.TAM.HOST.DETAILS.TRACE.ARCIB'
    F.TAM.HOST.DETAILS.TRACE.ARCIB = ''
    CALL OPF(FN.TAM.HOST.DETAILS.TRACE.ARCIB,F.TAM.HOST.DETAILS.TRACE.ARCIB)

    IP.POS = ''
    HOST.POS = ''
    LREF.POS = ''

    LREF.FLDS = 'IP.ADDRESS':@VM:'HOST.NAME' ;*AUTO R22 CODE CONVERSION
    LREF.POS = ''

    CALL MULTI.GET.LOC.REF(Y.APPL,LREF.FLDS,LREF.POS)
    IP.POS = LREF.POS<1,1>
    HOST.POS = LREF.POS<1,2>

RETURN

*-------
PROCESS:
*-------

* To check the channel [BROWSER (if null) OR ARC-IB(If internet/not null)]

    Y.EXT.CUST =  OFS$SOURCE.REC<OFS.SRC.CHANNEL>

    STR.TO.LOCATE = 'LOCAL.REF'

* TUT1276149 - Read on Standard Selection is replaced with a call to API [GET.STANDARD.SELECTION.DETS]
    CALL GET.STANDARD.SELECTION.DETS(Y.APPL, R.STANDARD.SELECTION)

    POS.LOC.REF = ''

* To find the position of Local reference fields in the application
    LOCATE 'LOCAL.REF' IN R.STANDARD.SELECTION<SSL.SYS.FIELD.NAME,1> SETTING POS1 THEN
        POS.LOC.REF = R.STANDARD.SELECTION<SSL.SYS.FIELD.NO,POS1>
    END

    IF Y.EXT.CUST EQ '' THEN
* If channel is browser, refer to TAM.HOST.DETAILS.TRACE table for details
        Y.ID = OPERATOR
        CALL F.READ(FN.TAM.HOST.DETAILS.TRACE,Y.ID,R.TAM.HOST.DETAILS.TRACE,F.TAM.HOST.DETAILS.TRACE,F.ERR)
        Y.HOST.NAME = R.TAM.HOST.DETAILS.TRACE<HOST.DET.HOST.NAME>
        Y.IP.ADDRESS = R.TAM.HOST.DETAILS.TRACE<HOST.DET.IP.ADDRESS>
    END ELSE
* If channel is ARC-IB, refer to TAM.HOST.DETAILS.TRACE.ARCIB table for details
        Y.ID = EB.EXTERNAL$USER.ID
        CALL F.READ(FN.TAM.HOST.DETAILS.TRACE.ARCIB,Y.ID,R.TAM.HOST.DETAILS.TRACE.ARCIB,F.TAM.HOST.DETAILS.TRACE.ARCIB,F.ERR)
        Y.HOST.NAME = R.TAM.HOST.DETAILS.TRACE.ARCIB<HOST.DET.IB.HOST.NAME>
        Y.IP.ADDRESS = R.TAM.HOST.DETAILS.TRACE.ARCIB<HOST.DET.IB.IP.ADDRESS>
    END

* Only applicable if application is having local reference fields IP.ADDRESS & HOST.NAME and the USER have a record in HOST.DETAIL.TRACE table

    IF (POS.LOC.REF NE '') AND (HOST.POS NE '') AND (IP.POS NE '') AND ((R.TAM.HOST.DETAILS.TRACE NE '') OR (R.TAM.HOST.DETAILS.TRACE.ARCIB NE '')) THEN

        IF V$FUNCTION EQ 'I' OR V$FUNCTION EQ 'R' THEN
* If User Inputs/Reverses, clear HOST.NAME & IP.ADDRESS fields & update the values in first multivalue set
            IF R.NEW(POS.LOC.REF)<1,HOST.POS> NE '' THEN
                R.NEW(POS.LOC.REF)<1,HOST.POS> = ''
                R.NEW(POS.LOC.REF)<1,IP.POS> = ''
            END
            R.NEW(POS.LOC.REF)<1,HOST.POS,1> = Y.HOST.NAME
            R.NEW(POS.LOC.REF)<1,IP.POS,1> = Y.IP.ADDRESS
        END

        IF V$FUNCTION EQ 'A' THEN
* If User Authorises, update the values in second multivalue set
            R.NEW(POS.LOC.REF)<1,HOST.POS,2> = Y.HOST.NAME
            R.NEW(POS.LOC.REF)<1,IP.POS,2> = Y.IP.ADDRESS
        END
    END

RETURN
*-------------------------------------------------------------------------------------------
CALL.TRACE.LOG:
*--------------
* R.OLD(V-7) is the field CURR.NO, No need to trace the record while initial creation.
* R.NEW(V-8) is the field RECORD.STATUS, to check for the status of the record to trace.

    Y.RECORD.STATUS = R.NEW(V-8)
    IF (((R.OLD(V-7) NE '' OR V$FUNCTION EQ "D") AND (Y.RECORD.STATUS[1,2] EQ "IN" OR Y.RECORD.STATUS[1,2] EQ "RN" OR V$FUNCTION EQ "D")) OR (R.NEW(V-7) EQ 1 AND Y.RECORD.STATUS[1,2] EQ "IN")) THEN
        APAP.REDOAPAP.redoApplAuditTrack(Y.HOST.NAME,Y.IP.ADDRESS,R.STANDARD.SELECTION) ;*MANUAL R22 CODE CONVERSION
    END

RETURN
*-------------------------------------------------------------------------------------------
END
