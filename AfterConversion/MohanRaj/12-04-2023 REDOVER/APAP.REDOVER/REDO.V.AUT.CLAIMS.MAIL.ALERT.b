* @ValidationCode : MjoyODM1MTA3NDI6Q3AxMjUyOjE2ODEyODQ4Nzg3MjY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:04:38
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.AUT.CLAIMS.MAIL.ALERT
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
* DESCRIPTION : A Authorisation routine iw written to send a mail to CUSTOMER once the
* notification is resolved and the routine is attached to REDO.ISSUE.CLAIMS
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : B RENUGADEVI
* PROGRAM NAME : REDO.V.AUT.CLAIMS.MAIL.ALERT
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE              WHO                REFERENCE         DESCRIPTION
* 20-AUG-2010       BRENUGADEVI        ODR-2009-12-0283  INITIAL CREATION
* 30-JUN-2010       MAIRMUTHU S        PACS00077652
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_RC.COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ENQUIRY.REPORT
    $INSERT I_F.REPORT.CONTROL
    $INSERT I_F.REDO.ISSUE.CLAIMS
    $INSERT I_F.REDO.ISSUE.EMAIL
    GOSUB INIT
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.REDO.ISSUE.CLAIMS = 'F.REDO.ISSUE.CLAIMS'
    F.REDO.ISSUE.CLAIMS  = ''
    CALL OPF(FN.REDO.ISSUE.CLAIMS,F.REDO.ISSUE.CLAIMS)

    FN.REDO.ISSUE.EMAIL  = 'F.REDO.ISSUE.EMAIL'
    F.REDO.ISSUE.EMAIL   = ''
    CALL OPF(FN.REDO.ISSUE.EMAIL,F.REDO.ISSUE.EMAIL)

    FN.ENQUIRY.REPORT   = 'F.ENQUIRY.REPORT'
    F.ENQUIRY.REPORT    = ''
    CALL OPF(FN.ENQUIRY.REPORT,F.ENQUIRY.REPORT)

RETURN

********
PROCESS:
********
    Y.ID                = ID.NEW
    Y.LAST.HOLD.ID      = C$LAST.HOLD.ID
    Y.CUS.MAIL.ID       = R.NEW(ISS.CL.EMAIL)
    Y.NOTIFICATION      = R.NEW(ISS.CL.CLOSE.NOTIFICATION)
    MSG.EXTRACT.FOLDER  = "&HOLD&"
*
    CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)
    Y.UNIQUE.ID         = UNIQUE.TIME
    FILENAME            = 'APAP-NOTIFICATION':Y.LAST.HOLD.ID:Y.UNIQUE.ID:'.TXT'
    FN.HRMS.FILE        = "B186_Mail_Folder"
    F.HRMA.FILE         = ""
    CALL OPF(FN.HRMS.FILE,F.HRMA.FILE)
    IF Y.NOTIFICATION EQ 'YES' THEN

* PACS00077652 - S
        MATBUILD Y.CK FROM R.NEW,1,500
*  PACS00077652  - E
        REP.NAME = "REDO.ENQ.CLAIM.MAIL.ALERT"

*    MATREAD R.NEW FROM F.ENQUIRY.REPORT, REP.NAME THEN ;*Tus Start
        ARRAY.SIZE = ''
        CALL F.MATREAD(FN.ENQUIRY.REPORT,REP.NAME,MAT R.NEW,ARRAY.SIZE,F.ENQUIRY.REPORT,R.NEW.ERR)
        IF NOT(R.NEW.ERR) THEN  ;* Tus End
            CALL ENQUIRY.REPORT.RUN
        END
* PACS00077652 -S
        MATPARSE R.NEW,1,500 FROM Y.CK
* PACS00077652 - E

        OPEN MSG.EXTRACT.FOLDER TO FILE.PTR THEN
        END
        READ R.FILE.REC FROM FILE.PTR,Y.LAST.HOLD.ID THEN

        END
        CALL CACHE.READ(FN.REDO.ISSUE.EMAIL,'SYSTEM',R.REDO.ISSUE.EMAIL,MAIL.ERR)
        BK.MAIL.ID    = R.REDO.ISSUE.EMAIL<ISS.ML.MAIL.ID>
        Y.FROM.MAIL   = BK.MAIL.ID
        Y.TO.MAIL     = Y.CUS.MAIL.ID
        Y.SUBJECT     = Y.ID:'-':"Notification Solved"
        Y.BODY        = R.FILE.REC

        RECORD = Y.FROM.MAIL:"#":Y.TO.MAIL:"#":Y.SUBJECT:"#":Y.BODY
        WRITE RECORD TO F.HRMA.FILE,FILENAME

    END
RETURN
END
