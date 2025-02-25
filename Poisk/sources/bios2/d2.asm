;--------------------------------------------------------------------------
; DISK_RESET (AH=00H)                                              :
;       ����� �������� �������                                     :
;                                                                  :
; �����:      DSKETTE_STATUS,CY �������� ����� ��������            :
;---------------------------------------------------------------------------
DISK_RESET      PROC    NEAR
        MOV     DX,03F2H                ; ����� ��������� ��������� ��������
        CLI                             ; ������ ����������
        MOV     AL,MOTOR_STATUS         ; ��������� ������ ��������� ���������
                                        ; ��������
        AND     AL,00111111B            ; ��������� ����� ��������� ������
        PUSH    CX
        MOV	CL,4
        ROL     AL,CL
        POP	CX                      ; ��������� ������ � ������� ����
                                        ; ����� ��������� � ������� �����
        OR      AL,00001000B            ; ���������� �������� ����������
        OUT     DX,AL                   ; ����� ��������
        MOV     SEEK_STATUS,0           ; ��������� ������ ���� ����������
        JMP     $+2                     ; �������� I/O
        JMP     $+2                     ; �������� I/O (������������)                               ;     PULSE WIDTH)
        OR      AL,00000100B            ; ��������� ���� ������
        OUT     DX,AL                   ; ����� ��������
        STI                             ; ���������� ����������
        CALL    WAIT_INT                ; �������� ����������
        JC      DR_ERR                  ; �������� ������ (���������� �� ���������)
        MOV     CX,11000000B            ; CL=EXPECTED NEC_STATUS

NXT_DRV:
        PUSH    CX
        MOV     AX,OFFSET DR_POP_ERR    ; �������� NEC_OUTPUT ������ ������
        PUSH    AX
        MOV     AH,08H                  ; ������� ��������� ������� ����������
        CALL    NEC_OUTPUT
        POP     AX
        CALL    RESULTS                 ; ������ ����������
        POP     CX
        JC      DR_ERR                  ; ������ - �������
        CMP     CL,NEC_STATUS           ; ���� ��� �������� �� ������
        JNZ     DR_ERR                  ; ��� OK
        INC     CL                      ; ��������� NEC_STATUS
        CMP     CL,11000011B            ; ��� ��������� ��������� �������
        JBE     NXT_DRV                 ; ������ ���� 11000100 ��� >

        CALL    SEND_SPEC               ; �������� ����������� ������� � NEC
RESBAC:
        CALL    SETUP_END               ; ��������� ������� ������
        MOV     BX,SI
        MOV     AL,BL
        RET

DR_POP_ERR:
        POP     CX
DR_ERR:
        OR      DISKETTE_STATUS,BAD_NEC  ; ��������� ���� ������
        JMP     SHORT RESBAC            ; �����
DISK_RESET      ENDP
;-----------------------------------------------------------------------
; DISK_STATUS   (AH=01H)                                            :
;       ������ ������� .                                            :
;    ���� :     AH= ������ ���������� ��������                      :
;                                                                   :
;   �����:      DSKETTE_STATUS,CY �������� ��������� �������        :
;--------------------------------------------------------------------------

DISK_STATUS     PROC    NEAR
        MOV     DISKETTE_STATUS,AH      ; ������������� ��� �������������
					; ����������� SETUP_END
	JMP	SHORT RESBAC            ; ������� �� :
					; CALL    SETUP_END
					; MOV     BX,SI
					; MOV     AL,BL
					; RET
DISK_STATUS     ENDP
;-------------------------------------------------------------------------
; DISK_READ     (AH=02H)                                                  :
;       ������ �������
; ��� ����� � ��� �������, ������ ����������� ����� ���������, �����      :
; ������� � �.�. ����������� � ��������� ��������:
;     ����:     DI      = ����� ���������                                 :
;               SI-���� = ���� �������                                    :
;               SI-���� = ���������� �������� ��������                    :
;               ES      = ��������� �������                               :
;               [BP]    = ����� �������                                   :
;               [BP+1]  = ����� �������                                   :
;               [BP+2]  = �������� ������                                 :
;                                                                         :
;   �����:      DISKETTE_STATUS,CY ������ ��������                        :
;--------------------------------------------------------------------------
DISK_READ       PROC NEAR
        AND     MOTOR_STATUS,01111111B  ; ��������� �������� ������
        MOV     AX,0E646H               ; AX= NEC �������, DMA �������
RD_OB:  CALL    RD_WR_VF                ; ��������� ������/������/�����������
        RET
DISK_READ       ENDP
;-------------------------------------------------------------------------
; DISK_WRITE    (AH=03H)                                                  :
;       ������ �������.                                                  :
;     ����:     DI      =  ����� ���������                                :
;               SI-HI   =  ���� �������                                   :
;               SI-LOW  =  ���������� �������� ��������                   :
;               ES      =  ��������� �������                              :
;               [BP]    =  ����� �������                                  :
;               [BP+1]  =  ����� �������                                  :
;               [BP+2]  =  �������� ������                                :
;                                                                         :
;   �����:      DSKETTE_STATUS,CY ������ ��������                         :
;--------------------------------------------------------------------------
DISK_WRITE      PROC NEAR
        MOV     AX,0C54AH               ; AX= NEC �������, DMA �������
        OR      MOTOR_STATUS,10000000B  ; ��������� �������� ������
	JMP	SHORT RD_OB
DISK_WRITE      ENDP
;-------------------------------------------------------------------------
; DISK_VERF     (AH=04H)                                                  :
;       ����������� �������                                               :
;     ����:     DI      =  ����� ���������                                :
;               SI-HI   =  ���� �������                                   :
;               SI-LOW  =  ���������� �������� ��������                   :
;               ES      =  ��������� �������                              :
;               [BP]    =  ����� �������                                  :
;               [BP+1]  =  ����� �������                                  :
;               [BP+2]  =  �������� ������                                :
;                                                                         :
;   �����:      DSKETTE_STATUS,CY ������ ��������                         :
;--------------------------------------------------------------------------
DISK_VERF       PROC NEAR
        AND     MOTOR_STATUS,01111111B  ; ��������� �������� ������
        MOV     AX,0E642H               ; AX= NEC �������, DMA �������
	JMP	SHORT RD_OB
DISK_VERF       ENDP
;-------------------------------------------------------------------------
; DISK_FORMAT   (AH=02H)                                                  :
;       �������������� �������                                            :
;     ����:     DI      = ����� ���������                                 :
;               SI-HI   = ���� �������                                    :
;               SI-LOW  = ���������� �������� ��������                    :
;               ES      = ��������� �������                               :
;               [BP]    = ����� �������                                   :
;               [BP+1]  = ����� �������                                   :
;               [BP+2]  = �������� ������                                 :
;               DISK_POINTER ��������� �� ������� ���������� �����        :
;                               ���������                                 :
;                                                                         :
;   �����:      DSKETTE_STATUS,CY ������ ��������                         :
;--------------------------------------------------------------------------
DISK_FORMAT    PROC NEAR
        CALL    XLAT_NEW                ; �������� ��������� ��� ���������� �������������
        CALL    FMT_INIT                ; ��������� ���������, ���� ������������
        OR      MOTOR_STATUS,10000000B  ; ��������� �������� ������
        CALL    MED_CHANGE              ; �������� ����� ��������
        JC      FM_DON                  ; �� ������, ������� ��������
        CALL    SEND_SPEC               ; ����������� �������  NEC
        CALL    CHK_LASTRATE            ; ZF=1 ��������, �������� �� �� ?
        JZ      FM_WR                   ; ��, ������� ����������� �������
        CALL    SEND_RATE               ; ��������� �������� ��������
FM_WR:
        CALL    FMTDMA_SET              ; ��������� DMA ��� ��������������
        JC      FM_DON                  ; ������� � �������
        MOV     AH,4DH                  ; ��������� ������� ��������������
        CALL    NEC_INIT                ; ������������� NEC
        JC      FM_DON                  ; ������ - �����
        MOV     AX,OFFSET FM_DON        ; �������� ������ ������
        PUSH    AX                      ; PUSH NEC_OUT ������
        MOV     DL,3                    ; BYTES/SECTOR �������� ��� NEC
        CALL    GET_PARM
        CALL    NEC_OUTPUT
        MOV     DL,4                    ; SECTORS/TRACK
        CALL    GET_PARM
        CALL    NEC_OUTPUT
        MOV     DL,7                    ; GAP LENGTH
        CALL    GET_PARM
        CALL    NEC_OUTPUT
        MOV     DL,8                    ; FILLER BYTE
        CALL    GET_PARM
        CALL    NEC_OUTPUT
        POP     AX                      ; ����������� ������
        CALL    NEC_TERM                ; ���������� � ��������� �������
FM_DON:
        CALL    XLAT_OLD                ; �������� ��������� ��� ����������� ������
        CALL    SETUP_END               ; �������
        MOV     BX,SI
        MOV     AL,BL
        RET
DISK_FORMAT     ENDP
;--------------------------------------------------------------------------
; FNC_ERR                                                                 :
;       ������������ ������� ��� ������������ ��������                    :
;       ��������� ������������ ������� � �������                          :
;                                                                         :
;   �����:      DSKETTE_STATUS,CY ������ ��������                         :
;--------------------------------------------------------------------------
FNC_ERR          PROC    NEAR
        MOV     AX,SI
        MOV     AH,BAD_CMD
        MOV     DISKETTE_STATUS,AH
        STC                             ; ��������� ����� ������
        RET
FNC_ERR          ENDP
;----------------------------------------------------------------
; DISK_PARMS  (AH=08H)                                           :
;       ������ ���������� ���������                              :
;     ����:                                                      :
;       DI = ����� ���������                                     :
;   �����:                                                       :
;       CL/[BP]  = ���� 7&6 ������� 2 ���� ����. ����� ��������� :
;                  ���� 0-5 ���� ������/����                     :
;       CH/[BP+1]= ��. 8 ��� ����. ����� ���������               :
;       BL/[BP+2]= ���� 7-4 = 0                                  :
;                  ���� 3-0 = ��� ��������� �� ����              :
;       BH/[BP+3]= 0                                             :
;       DL/[BP+4]= �-�� ������������ ����������                  :
;       DH/[BP+5]= ������������ ����� �������                    :
;       DI/[BP+6]= �������� ������� ��������/��������            :
;       ES       = ������� �������                               :
;       AX       = 0                                             :
; NOTE  : �������, ��� ���������� ������������ ����� ������ ��   :
;         ����� � ����������� ��� ��������, ����� �������� ��    :
;         ���������                                              :
;----------------------------------------------------------------
DISK_PARMS          PROC    NEAR
        CALL    XLAT_NEW                ; ��������� ������������� ��������
        MOV     WORD PTR [BP+2],0       ; ��� ��������� = 0
        MOV     AX,EQUIP_FLAG           ; ������ ����� ������������ ��� ������
        AND     AL,11000001B            ; ����� ����� ����������
        MOV     DL,2                    ; ��������� = 2
        CMP     AL,01000001B            ; ���������� 2 ?
        JZ      STO_DL                  ; ������� ���� ��
        DEC     DL                      ; �������� =1
        CMP     AL,00000001B            ; ��������� 1?
        JNZ     NON_DRV                 ; ������� ���� �� ������
STO_DL:
        MOV     [BP+4],DL               ; �������������� ����� ����������
        CMP     DI,1                    ; �������� ������������ ������ ���������
        JA      NON_DRV1                ; �����������
        MOV     BYTE PTR[BP+5],1        ; ������������ ����� ������� = 1
        CALL    CMOS_TYPE               ; ��� ��������� � AL
        JC      CHK_EST                 ; ������ ����
        OR      AL,AL                   ; ���� ���������� ���������
        JZ      CHK_EST                 ; ������� ���� �����������
        CALL    DR_TYPE_CHECK           ; ��������� SEG:OFFSET ������� ���/����.
        JC      CHK_EST                 ; JMP ���� �������������� ����
        MOV     [BP+2],AL               ; �������������� ���� �� ����
        MOV     CL,CS:[BX].MD_SEC_TRK   ; ��������� ������/�������
        MOV     CH,CS:[BX].MD_MAX_TRK   ; ��������� ������������� ����� ��������
        JMP     SHORT STO_CX            ; ���� �������.,���������� ����
CHK_EST:
        MOV     AH,DSK_STATE[DI]        ; �������� ��������� ����� ���������
        TEST    AH,MED_DET              ; �������� ��������� ���������
        JZ      NON_DRV1                ; ������ ����

USE_EST:
        AND     AH,RATE_MSK             ; ��������� ��������
        CMP     AH,RATE_250             ; �������� ? 250
        JNE     USE_EST2                ; ���, �������� ������ ���������

;----�������� 250 KBS, �������� ������� 360 KB
        MOV     AL,01                   ; ��� ��������� 1 (360KB)
        CALL    DR_TYPE_CHECK           ; ��������� CX:BX = ������� ����������
        MOV     CL,CS:[BX].MD_SEC_TRK   ; ��������� ������/���.
        MOV     CH,CS:[BX].MD_MAX_TRK   ; ������. ����� ��������
        TEST    DSK_STATE[DI],TRK_CAPA  ; 80 ���. ?
        JZ      STO_CX                  ; ������ ���� 360KB ��������

; ---���� ��� 1.44 ��������

PARM144:
        MOV     AL,04                   ; ��� 4 (1.44MB)
        CALL    DR_TYPE_CHECK           ; ��������� CX:BX = ������� ����������
        MOV     CL,CS:[BX].MD_SEC_TRK   ; ��������� ������/���.
        MOV     CH,CS:[BX].MD_MAX_TRK   ; ������. ����� ��������
STO_CX:
        MOV     [BP],CX                 ; ������ � ���� ��� ��������
        MOV     [BP+6],BX               ; ����� �������
        MOV     AX,CS                   ; ������� �������
        MOV     ES,AX                   ; ES �������
DP_OUT:
        CALL    XLAT_OLD                ; ��� �������������
        XOR     AX,AX                   ; �������
        CLC
        RET

;-------- ��������� ���������� ���������

NON_DRV:
        MOV     BYTE PTR [BP+4],0       ; ������� ����� ����������
NON_DRV1:
        CMP     DI,80H                  ; �������� ������� �������� �����
        JB      NON_DRV2                ; ����������� ���� �� �������

;--------������� ����, ������ �������

        CALL    XLAT_OLD                ; ��� ��� �������������
        MOV     AX,SI                   ; �������������� AL
        MOV     AH,BAD_CMD              ; ��������� ������ - ������������ �������
        STC                             ; ��������� ������
        RET

NON_DRV2:
        XOR     AX,AX                ; ������� ���������� ���� ��� ���������
				     ; ��� ������ ����
        MOV     [BP],AX              ; �������, ������/����� = 0
        MOV     [BP+5],AH            ; ���. = 0
        MOV     [BP+6],AX            ; �������� DISK_BASE = 0
        MOV     ES,AX                ; �������
        JMP     SHORT DP_OUT

;------- �������� �������� 300KBS ��� 500 KBS,������� ������� 1.2 MB

USE_EST2:
        MOV     AL,02                   ; ��� ������. 1 (1.2MB)
        CALL    DR_TYPE_CHECK           ; ��� CX:BX = �����/�������� �������
        MOV     CL,CS:[BX].MD_SEC_TRK   ; ��������� ������/���.
        MOV     CH,CS:[BX].MD_MAX_TRK   ; ����. ����� �������
        CMP     AH,RATE_300             ; ���� 300 ?
        JE      STO_CX                  ; ������ ���� 1.2MB ��������
        JMP     SHORT PARM144           ; ��� ����� ���� 1.44MB ��������

DISK_PARMS          ENDP

;-----------------------------------------------------------------
;  DISK_TYPE    (AH=15H)                                         :
;       ��� ��������� ���������� ��� ���������                   :
;       ����:   DI = ����� ���������                             :
;                                                                :
;     �����:    AH = ��� ���������, CY=0                         :
;-----------------------------------------------------------------
DISK_TYPE          PROC    NEAR
        CALL    XLAT_NEW                ; ��� �������������
        MOV     AL,DSK_STATE[DI]        ; ��������� ���������
        OR      AL,AL                   ; �������� ������� ���������
        JZ      NO_DRV
        MOV     AH,NOCHGLN              ; ��� ����� ����� ����� ��� 40 �����.���.
        TEST    AL,TRK_CAPA             ; ��� ��� 80 ��������?
        JZ      DT_BACK                 ; ���� ��� JUMP
        MOV     AH,CHGLN

DT_BACK:
        PUSH    AX                      ; ������ ������������� ��������
        CALL    XLAT_OLD                ; ��� �������������
        POP     AX                      ; �������������� ������������ ��������
        CLC                             ; ��� ������
        MOV     BX,SI                   ;
        MOV     AL,BL                   ;
        RET

NO_DRV:
        XOR     AH,AH                   ; ��� ��������� ��� �������������� ���
        JMP     SHORT DT_BACK
DISK_TYPE          ENDP
;-----------------------------------------------------------------
;  DISK_CHANGE  (AH=16H)                                         :
;       ��� ��������� ���������� ��������� ����� ����� �����     :
;                                                                :
;      ����:    DI = ����� ���������                             :
;                                                                :
;    �����:     AH = DSCETTE_STATUS                              :
;                    00 - ����� ���������, CY = 0                :
;                    06 - ����� �������  , CY = 1                :
;-----------------------------------------------------------------
DISK_CHANGE          PROC    NEAR
	not	uppp
        CALL    XLAT_NEW                ; ��� �������������
        MOV     AL,DSK_STATE[DI]        ; ��������� ����������
        OR      AL,AL                   ; �������� ������������?
        JZ      DC_NON                  ; ������� ���� ���
        TEST    AL,TRK_CAPA             ; 80 ���������� ?
        JZ      SETIT                   ; ���� ���, �������� ����� ����� �����

DCO:    CALL    READ_DSKCHNG            ; ��������� ��������� �����
        JZ      FINIS                   ; ����� ���������

SETIT:  MOV     DISKETTE_STATUS,MEDIA_CHANGE    ; ��������� �����

FINIS:  CALL    XLAT_OLD                ; ��� �������������
        CALL    SETUP_END               ; �������
        MOV     BX,SI
        MOV     AL,BL
        RET

DC_NON:
        OR      DISKETTE_STATUS,TIME_OUT        ; ��������� TIMEOUT,��� ���������
        JMP     SHORT FINIS
DISK_CHANGE     ENDP

;----------------------------------------------------------------
;  FORMAT_SET   (AH=17H)                                         :
;       ��� ��������� ������������ ��� ����������� ����          :
;       �������� ��� �������� ��������������                     :
;                                                                :
;      ����:    SI ��. = ��� �������                             :
;               DI     = ����� ���������                         :
;                                                                :
;    �����:     DSKETTE_STATUS �������� ������ ��������          :
;               AH = DSKETTE_STATUS                              :
;               CY = 1 ���� ������                               ;
;-----------------------------------------------------------------
FORMAT_SET          PROC    NEAR
        CALL    XLAT_NEW                ; ��� �������������
        PUSH    SI                      ; ������ ��� ��������
        MOV     AX,SI                   ; AH = ? , AL = ��� ��������
        XOR     AH,AH                   ; AH = 0 , AL = ��� ��������
        MOV     SI,AX                   ; SI = ��� ��������
        AND     DSK_STATE[DI],NOT MED_DET+DBL_STEP+RATE_MSK     ; ������� ����.
        DEC     SI                      ; ����.��� 320/360K ��������
        JNZ     NOT_320                 ; ����� ���� ���
        OR      DSK_STATE[DI],MED_DET+RATE_250          ; ��������� 320/360
        JMP     SHORT SO
NOT_320:
        CALL    MED_CHANGE              ; ����. ��� TIME_OUT
        CMP     DISKETTE_STATUS,TIME_OUT
        JZ      SO                      ; ���� ����� ����� �����

ss3:     DEC     SI                     ; �������� ��� 320/360K � 1.2
        JNZ     NOT_320_12              ; ����� ���� ���
        OR      DSK_STATE[DI],MED_DET+DBL_STEP+RATE_300  ; ��������� ���������
        JMP     SHORT SO
NOT_320_12:
        DEC     SI                      ; �������� ��� 1.2M ������.� 1.2M ������.
        JNZ     NOT_12                  ; ����� ���� ���
        OR      DSK_STATE[DI],MED_DET+RATE_500  ; ��������� ����������� ���������
        JMP     SHORT SO                ; �������
NOT_12:
        DEC     SI                      ; �������� 4 ���� ��������
        JNZ     FS_ERR                  ; ������������ �������,�����. �����

        TEST    DSK_STATE[DI],DRV_DET   ; �������� �������.?
        JZ      ASSUM                   ; ���� �����������, �� ������������
					; ���������
        MOV     AL,MED_DET+RATE_300
        TEST    DSK_STATE[DI],FMT_CAPA  ; ����������� ��������������� ?
        JNZ     OR_IT_IN                ; ���� 1.2M ����� �������� 300
ASSUM:
        MOV     AL,MED_DET+RATE_250    ; ���������
OR_IT_IN:
        OR      DSK_STATE[DI],AL        ; OR ��� ���������� ���������
SO:
        CALL    XLAT_OLD                ; ��� �������������
        CALL    SETUP_END               ; �������
        POP     BX
        MOV     AL,BL
        RET
FS_ERR:
        MOV     DISKETTE_STATUS,BAD_CMD  ; �������������� ���������, ������.�������
        JMP     SHORT SO                ;
FORMAT_SET          ENDP

; ----------------------------------------------------------------
;  SET_MEDIA    (AH=18)                                          :
;       ��� ��������� ������������� ��� �������� � ��������      :
;       �������� ������������ ��� ��������������                 :
;      ����:                                                     :
;       [BP]   = �������� �� ����                                :
;       [BP+1] = ����� �����                                     :
;       DI     = ����� ���������                                 :
;    �����:                                                      :
;       DSKETTE_STATUS �������� ������                           :
;       ���� ��� ������:                                         :
;               AH = 0                                           :
;               CY = 0                                           :
;               ES = ������� ������� ��������/��������           :
;               DI/[BP+6] = ��������                             :
;      ���� ������:                                              :
;               AH = DSKETTE_STATUS                              :
;               CY = 1                                           :
;-----------------------------------------------------------------
SET_MEDIA          PROC    NEAR
        CALL    XLAT_NEW                ; ��� �������������
        TEST    DSK_STATE[DI],TRK_CAPA  ; �������� ������� ����� ����� �����
        JZ      SM_CMOS                 ; JUMP ���� 40 ����������
        CALL    MED_CHANGE              ; �������� �������
        CMP     DISKETTE_STATUS,TIME_OUT   ; ����� ���� ����� �����
        JE      SM_RTN
        MOV     DISKETTE_STATUS,0        ; ������� �������
SM_CMOS:
        CALL    CMOS_TYPE               ; ��� ��������� � (AL)
        JC      MD_NOT_FND              ; ������ ����
        OR      AL,AL                   ; ���� ������� ���������
        JZ      SM_RTN                  ; ����� ���� ���
        CALL    DR_TYPE_CHECK           ; ��� CX:BX = ������� ��������/��������
        JC      MD_NOT_FND              ; ��� � ������� �����������, ������ ����
        PUSH    DI
        XOR     BX,BX                   ; BX = ������ DRV_TYPE �������
        MOV     CX,6                    ; CX = ������� ����������

DR_SEARCH:
        MOV     AH,CS:DR_TYPE[BX]       ; ��������� ���� ���������(F000:20E9=1)
        AND     AH,BIT7OFF              ; �����
        CMP     AL,AH                   ; ��������� ���� ��������� ?
        JNE     NXT_MD                  ; ���, �������� ���������� ���� ���������

        MOV     DI,CS:WORD PTR DR_TYPE[BX+1]    ; DI=��������/��������
        MOV     AH,CS:[DI].MD_SEC_TRK   ; ��������� ������/�����.
        CMP     [BP],AH                 ; ��������� ?
        JNE     NXT_MD                  ; ���, �������� ����.��������
        MOV     AH,CS:[DI].MD_MAX_TRK   ; �������� ����. ����� �������
        CMP     [BP+1],AH               ; ����. ?
        JE      MD_FND                  ; ��, ��������� �������� ��������
NXT_MD:
        ADD     BX,3                    ; �������� ���������� ���� ���������
        LOOP    DR_SEARCH
        POP     DI                      ; ��������������
MD_NOT_FND:
        MOV     DISKETTE_STATUS,MED_NOT_FND  ; ������, ������� ������� ���� �� �������
        JMP     SHORT SM_RTN                 ; �����
MD_FND:
        MOV     AL,CS:[DI].MD_RATE      ; ��������� ��������
        CMP     AL,RATE_300             ; ������� ��� ��� �������� 300
        JNE     MD_SET
        OR      AL,DBL_STEP
MD_SET:
        MOV     [BP+6],DI               ; ������ ������� ���������� � ����
        OR      AL,MED_DET              ; ��������� "��������"
        POP     DI                      ; �������������� ���������
        AND     DSK_STATE[DI],NOT MED_DET+DBL_STEP+RATE_MSK  ; ������� ���������
        OR      DSK_STATE[DI],AL        ; ��������� ���������
        MOV     AX,CS                   ; ������� ��������/��������
        MOV     ES,AX                   ; ES �������
SM_RTN:
        CALL    XLAT_OLD
        CALL    SETUP_END
        RET
SET_MEDIA          ENDP

; ----------------------------------------------------------------
;  DR_TYPE_CHECK                                                 :
;       �������� ������������ ���� ��������� �  (AL)             :
;       �������� ���������� � BIOS                               :
;      ����:                                                     :
;       AL = ��� ���������                                       :
;    �����:                                                      :
;       CS = ������� ������� ��������/��������                   :
;       CY = 0 ������ ��� ��������� ��������������               :
;               BX = �������� �������                            :
;       CY = 1  ��� ��������� ����������������                   :
;  ��������:  BX                                                 :
;-----------------------------------------------------------------
DR_TYPE_CHECK          PROC    NEAR
        PUSH    AX
        PUSH    CX
        XOR     BX,BX                   ; BX = ������ � DR_TYPE �������
        MOV     CX,DR_CNT               ; CX = ������� ����������

TYPE_CHK:
        MOV     AH,CS:DR_TYPE[BX]       ; ��������� ���� ��������� (F000:20E9=1)
        CMP     AL,AH                   ; ��������� ���� �� ���� � ����������
        JE      DR_TYPE_VALID           ; ��, ����� � ���������� ������
        ADD     BX,3                    ; �������� ���������� ���� ���������
        LOOP    TYPE_CHK
        STC                             ; ������ ��� ��������� �� ������ � ���.
        JMP     SHORT TYPE_RTN
DR_TYPE_VALID:
        MOV     BX,CS:WORD PTR DR_TYPE[BX+1]    ; BX = �������� ������� �����/���.
TYPE_RTN:
        POP     CX
        POP     AX
        RET
DR_TYPE_CHECK          ENDP

; ----------------------------------------------------------------
;  SEND_SPEC                                                        :
;       �������� ����������� ������� � ���������� ��������� ���-    :
;       ��� �� ������� ���������� �� ������� ��������� DISK_POINTER :
;  ����:    DISK_POINTER = ������� ���������� ���������             :
;  �����:     ���                                                   :
;  ��������:  CX,BX                                                 :
;-----------------------------------------------------------------
SEND_SPEC          PROC    NEAR
        PUSH    AX
        MOV     AX,OFFSET SPECBAC       ; �������� ������ ������
        PUSH    AX
        MOV     AH,03H                  ; ����������� �������
        CALL    NEC_OUTPUT              ; ��������������� NEC
        SUB     DL,DL                   ; ������ ���� ����������
        CALL    GET_PARM                ; ��������� ��������� � AH
        CALL    NEC_OUTPUT              ; ����� ������
        MOV     DL,1                    ; ��������� ����     
        CALL    GET_PARM                ; ��������� ��������� � AH
        CALL    NEC_OUTPUT              ; ����� �������     
        POP     AX                      
SPECBAC:
        POP     AX                      
        RET
SEND_SPEC          ENDP

; ----------------------------------------------------------------
;  SEND_SPEC_MD                                                  :
;       ������� ����������� ������� � ����������,������������    :
;       ������ �� ������� ��������/�������� � ����.(CX:BX)       :
;      ����:    CX:BX = ����������� �������                      :
;    �����:     ���                                              :
;-----------------------------------------------------------------
SEND_SPEC_MD          PROC    NEAR
        PUSH    AX                      
        MOV     AX,OFFSET SPEC_ESBAC    ; �������� ������ ������
        PUSH    AX                      ; ���������� ������        
        MOV     AH,03H                  ; ����������� �������
        CALL    NEC_OUTPUT              ; ����� �������     
        MOV     AH,CS:[BX].MD_SPEC1     ; ��������� ������� ������������ �����
        CALL    NEC_OUTPUT              ; ����� �������     
        MOV     AH,CS:[BX].MD_SPEC2     ; ��������� ������������ �����
        CALL    NEC_OUTPUT              ; ����� �������     
        POP     AX                      
SPEC_ESBAC:
        POP     AX                      
        RET
SEND_SPEC_MD          ENDP              

; ----------------------------------------------------------------
;  XLAT_NEW                                                      :
;       ����������� ������� ������� ������� ��� ����������       :
;       �������������                                            :
;      ����:    DI:��������                                      :
;-----------------------------------------------------------------

XLAT_NEW          PROC    NEAR
        CMP     DI,1                    ; ���������� ����� ��������� ?
        JA      XN_OUT                  ; ���������
        CMP     DSK_STATE[DI],0         ; ��������� ?
        JZ      DO_DET                  ; ���� ��� ������� �����������
        MOV     CX,DI                   ; CX = ����� ���������
        SHL     CL,1                    ; CL = �����  ,A=0,B=4
        SHL	CL,1
        MOV     AL,HF_CNTRL             ; ���������� � ���������
        ROR     AL,CL                   ; ��������� ���������������� �����
        AND     AL,DRV_DET+FMT_CAPA+TRK_CAPA    ; ��������� ����������� ���
        AND     DSK_STATE[DI],NOT DRV_DET+FMT_CAPA+TRK_CAPA
        OR      DSK_STATE[DI],AL        ; ��������� ��������� ���������
XN_OUT:
                RET
DO_DET:
                CALL    DRIVE_DET       ; ����������� ���������
                RET
XLAT_NEW          ENDP

; ----------------------------------------------------------------
;  XLAT_OLD                                                      :
;       �������� ������������ ������� ��������/��������          :
;       �� ������ ����������� ��� ����������� �������������      :
;      ����:    DI:��������                                      :
;-----------------------------------------------------------------
XLAT_OLD          PROC    NEAR
        CMP     DI,1                    ; ������������ ������ ��������� ?
        JA      XN_OUT                  ; ���� ������������
        CMP     DSK_STATE[DI],0         ; ��� ��������� ?
        JE      XN_OUT                  ; ���� ���

;-------   ���� ���� ���������� � ��������� ��� �����������

        MOV     CX,DI                   ; CX = ����� ���������
        SHL     CL,1                    ; CL = ����� ,A=0,B=4
        SHL	CL,1
        MOV     AH,FMT_CAPA             ; �������� ����� ��������������� ������.
        ROR     AH,CL                   ; �������� �����
        TEST    HF_CNTRL,AH             ; ����������� �� ����� ������������. ?
        JNZ     SAVE_SET                ; ���� ��, �� �� ��������� � �������������

;-------  ������� ��� ��������� � HF_CNTRL ��� ����� ���������

        MOV     AH,DRV_DET+FMT_CAPA+TRK_CAPA    ; �����
        ROR     AH,CL
        NOT     AH
        AND     HF_CNTRL,AH

;-------  ������ � �������� ��������� � ��������� � HF_CNTRL

        MOV     AL,DSK_STATE[DI]        ; ��������� ���������
        AND     AL,DRV_DET+FMT_CAPA+TRK_CAPA    ; ��������� ��� ���������
        ROR     AL,CL                   ; ��� ���������� ���������
        OR      HF_CNTRL,AL             ; ������ ����������� ���������

;------�������� ��� �������������    

SAVE_SET:
        MOV     AH,DSK_STATE[DI]        ; ������ � ���������
        MOV     BH,AH                   ; � BH ��� ���������
        AND     AH,RATE_MSK             ; ��������� ��������
        CMP     AH,RATE_500             ; ���� 500 ?
        JZ      CHK_144                 ; �� 1.2/1.2 ��� 1.44/1.44
        MOV     AL,M3D1U                ; AL =360 � 1.2 
        CMP     AH,RATE_300             ; ���� 300 ?
        JNZ     CHK_250                 ; ���,360/360,720/720 ��� 720/1.44
        TEST    BH,DBL_STEP             ; ��,������� ��� ?
        JNZ     TST_DET                 ; ��, ��� 360 � 1.2 
UNKNO:
        MOV     AL,MED_UNK              ; '����� �� ������'
        JMP     SHORT AL_SET            ; ������� ��������
CHK_144:
        CALL    CMOS_TYPE               ; ��� ��������� � (AL)
        JC      UNKNO                   ; ������ ��������� '�� ������'
        CMP     AL,02                   ; 1.2MB �������� ?
        JNE     UNKNO                   ; ���,��������� '����� �� ������'
        MOV     AL,M1D1U                ; AL = 1.2 � 1.2
        JMP     SHORT TST_DET
CHK_250:
        MOV     AL,M3D3U                ; AL = 360 � 360 
        CMP     AH,RATE_250             ; ���� 250 ?
        JNE     UNKNO                   ; ���� ���
        TEST    BH,TRK_CAPA             ; 80 ������  ?
        JNZ     UNKNO                   
TST_DET:
        TEST    BH,MED_DET              ; ��������� ?
        JZ      AL_SET                  ; ���� ���, ����� �������������
        ADD     AL,3                    ; ������ ���������/����������
AL_SET:
        AND     DSK_STATE[DI],NOT DRV_DET+FMT_CAPA+TRK_CAPA     ; ������� ���������
        OR      DSK_STATE[DI],AL        ; ����������� ��� ����������� ������
XO_OUT:
        RET
XLAT_OLD          ENDP

; ----------------------------------------------------------------
;  RD_WR_VF                                                      :
;       ��������� ������, ������ � �����������                   :
;       �������� ���� ��� ����������                             :
;      ����:    AH : ��������� NEC ��� ������, ������, �������.  :
;               AL : ��������� DMA ��� ������, ������, �������.  :
;    �����:     DSKETTE_STATUS, CY ������ ��������               :
;-----------------------------------------------------------------

RD_WR_VF          PROC    NEAR
        PUSH    AX                      ; ���������� ���������� DMA � NEC
        CALL    XLAT_NEW                ; ����������� ��������� �������. ����.
        CALL    SETUP_STATE             ; �������������� ��������� � ��������
					; �������� � ������ ����������������
					; ��������� � ���� ��������
        POP     AX                      ; ��������������
DO_AGAIN:
        PUSH    AX                      ; ���������� ���������� DMA � NEC
        CALL    MED_CHANGE              ; �������� ����� ������� � ������

        POP     AX
        JNC     RWV
        JMP     RWV_END
RWV:
        PUSH    AX
        MOV     DH,DSK_STATE[DI]        ; ��������� ��������
        AND     DH,RATE_MSK
        CALL    CMOS_TYPE               ; ��� ��������� � (AL)
        JC      RWV_ASSUME              ; ������ � CMOS
        CMP     AL,1                    ; 40 �������� �������� ?
        JNE     RWV_1                   ; ���, ����� ������������ CMOS
        TEST    DSK_STATE[DI],TRK_CAPA  ; �������� ��� 40 ��������� ���������
        JZ      RWV_2                   ; ��, CMOS ���������
        MOV     AL,2                    ; ����� 1.2M
        JMP     SHORT RWV_2             ; �����������
RWV_1:
        JB      RWV_2                   ; �������� �� ���������
        TEST    DSK_STATE[DI],1         ; ���� ��� 40 �������� ?
        JNZ     RWV_2                   ; ��� 80 ������
        MOV     AL,1                    ; ���� 40 ������, �� ����������� CMOS
RWV_2:
        OR      AL,AL
        JZ      RWV_ASSUME              ; ������������ ������������ �-�� �������
        CALL    DR_TYPE_CHECK           ; CX:BX = ������� ���������� ��������/��������
        JC      RWV_ASSUME              ; ���� ��� � �������(������ CMOS)

;------ ����� ��� ������� ���������� ��������/��������

        PUSH    DI                      ; ���������� ������ ���������
        XOR     BX,BX                   ; BX = ����� � DR_TYPE �������
        MOV     CX,DR_CNT               ; CX = ������� ����������
RWV_DR_SEARCH:
        MOV     AH,CS:DR_TYPE[BX]       ; ��������� ���� ���������
        AND     AH,BIT7OFF              ; ����� 7 ����
        CMP     AL,AH                   ; ��� ��������� ?
        JNE     RWV_NXT_MD              ; ��� �������� ���������� ����
RWV_RR_FND:
        MOV     DI,WORD PTR CS:DR_TYPE[BX+1]    ; ��������/�������� ������� ����������
RWV_MD_SEARCH:
        CMP     DH,CS:[DI].MD_RATE      ; ��������� ?
        JE      RWV_MD_FND              ; ��, ��������� ������� �����
RWV_NXT_MD:
        ADD     BX,3                    ; �������� ���������� ���������
        LOOP    RWV_DR_SEARCH
        POP     DI                      ; �������������� ������ ���������

;------- ������������ ��� ������ �������� �������

RWV_ASSUME:
        MOV     BX,OFFSET MD_TBL1       ; ��������� �� 40 ��� � �������� 250
        TEST    DSK_STATE[DI],TRK_CAPA  ; ���� ��� 80 �������
        JZ      RWV_MD_FND1             ; ����� ���� 40 �������
        MOV     BX,OFFSET MD_TBL3       ; ��������� �� 80 �� 500 KBS
	JMP     short RWV_MD_FND1             ; ��������� ����������� ����������

;------- CS:BX ��������� �� ������� ��������/��������

RWV_MD_FND:
        MOV     BX,DI
	POP     DI                      ; �������������� ������ ���������
RWV_MD_FND1:

;-------- ������� ����������� ������� � NEC ����������

        CALL    SEND_SPEC_MD
        CALL    CHK_LASTRATE            ; ZF = 1 ������� �������� ��� � ����-
					; ������ ��������
        JZ      RWV_DBL                 ; ��, ������� ������� ��������� ��������
        CALL    SEND_RATE               ; ��������� �������� ��������
RWV_DBL:
        PUSH    BX                      ; ���������� ������ �������
        CALL    SETUP_DBL               ; �������� ��� �������� ����
        POP     BX                      ; �������������� ������
        JC      CHK_RET                 ; ������ ������, �������� ����������
        POP     AX                      ; �������������� NEC, DMA ������
        PUSH    AX                      ; ����������
        PUSH    BX
        CALL    DMA_SETUP               ; ��������������� DMA
        POP     BX
        POP     AX                      ; �������������� NEC �������
        JC      RWV_BAC                 ; �������� ������ DMA
        PUSH    AX                      ; ���������� NEC �������
        PUSH    BX                      ; ���������� ������
        CALL    NEC_INIT                ; ������������� NEC
        POP     BX                      ; �������������� ������
        JC      CHK_RET                 ; �����-������
        CALL    RWV_COM                 ; ��� ������/������/�����������
        JC      CHK_RET                 ; �����-������
        CALL    NEC_TERM                ; ���������� ��������� �������
CHK_RET:
        CALL    RETRY                   ; �������� ��� �������
        POP     AX                      ; �������������� ���������� ��/���/���
        JNC     RWV_END                 ; CY = 0 �� ���������
        JMP     DO_AGAIN                ; CY = 1 ���������
RWV_END:
        CALL    DSTATE                  ; ��������� ���������, ���� �����
        CALL    NUM_TRANS               ; AL = ������������ �����
RWV_BAC:
        PUSH    AX                      ; ����������
        CALL    XLAT_OLD                ; �������� ��� �������������
        POP     AX
        CALL    SETUP_END               ; �������
        RET
RD_WR_VF          ENDP
;--------------------------------------------------------------------
;  SETUP_STATE:    ������������ ��������� � �������� ��������        :
;--------------------------------------------------------------------
SETUP_STATE          PROC    NEAR
        TEST    DSK_STATE[DI],MED_DET   ; ������� ���������� ?
        JNZ     J1C                     ; �������, ���� ����������
        MOV     AX,0040H                ; AH = ��������� ��������_500,
					; AL=�������� ��������_300
        TEST    DSK_STATE[DI],DRV_DET   ; �������� ��������� ?
        JZ      AX_SET                  ; �� ���� ����������
        TEST    DSK_STATE[DI],FMT_CAPA  ; �����-���������� (1.2M) ?
        JNZ     AX_SET                  ; JUMP ���� ��
        MOV     AX,8080H                ; ��������� �������� = 250 ��� 360 ���������
AX_SET:
        AND     DSK_STATE[DI],NOT RATE_MSK+DBL_STEP     ; ���������� ����� ��������
        OR      DSK_STATE[DI],AH        ; ��������� �������� 250
        AND     LASTRATE,NOT STRT_MSK   ; �������� ���������� ���� ��������
        PUSH    CX
        MOV	CL,4
        ROR     AL,CL
        POP	CX                      ; ��������� ��������
        OR      LASTRATE,AL
J1C:
        RET
SETUP_STATE          ENDP
;--------------------------------------------------------------------
;  FMT_INIT: ��������� ���������, ���� ����� �������������� �� �����������
;--------------------------------------------------------------------
FMT_INIT        PROC    NEAR
        TEST    DSK_STATE[DI],MED_DET   ; �������� ����������
        JNZ     FI_OUT                  ; ���� ��� - �����
        CALL    CMOS_TYPE               ; ��� ��������� � AL
        JC      CL_DRV                  ; ������ ����, ������������ ������-
					; ���� ���������
        DEC     AL                      ; ��������� ���������� ���������
        JS      CL_DRV                  ; ��� ��������� ���� 0
        MOV     AH,DSK_STATE[DI]        ; AH = ������� ���������
        AND     AH,NOT MED_DET+DBL_STEP+RATE_MSK        ; �������
        OR      AL,AL                   ; �������� ��� 360
        JNZ     N_360                   ; ���� 360 �� 0
        OR      AH,MED_DET+RATE_250     ; ��������� ��������
        JMP     SHORT SKP_STATE         ; ������� ������ ���������
N_360:
        DEC     AL                      ; 1.2 M ��������
        JNZ     N_12                    ; JUMP ���� ���
FI_RATE:
        OR      AH,MED_DET+RATE_500     ; ��������� �������� ��������������
        JMP     SHORT SKP_STATE         ; ������ ������ ���������
N_12:
        DEC     AL                      ; �������� 3 ����
        JNZ     N_720                   ; JUMP ���� ���
        TEST    AH,DRV_DET              ; �������� ���������
        JZ      ISNT_12                 ; ��������� ��� �� 1.2
        TEST    AH,FMT_CAPA             ; 1.2 M
        JZ      ISNT_12                 ; JUMP ���� ���
        OR      AH,MED_DET+RATE_300     ; 300
        JMP     SHORT SKP_STATE         ; �����������
N_720:
        DEC     AL                      ; �������� ��� ���� 4
        JNZ     CL_DRV                  ; ��� ���������, ������ ����
        JMP     SHORT FI_RATE
ISNT_12:
        OR      AH,MED_DET+RATE_250     ; �������� 250
SKP_STATE:
        MOV     DSK_STATE[DI],AH        ; ���������
FI_OUT:
        RET
CL_DRV:
        XOR     AH,AH                   ; ������� ���������
        JMP     SHORT SKP_STATE         ; ������ ���
FMT_INIT        ENDP
; ----------------------------------------------------------------
;  MED_CHANGE                                                    :
;       �������� ����� �������, ����� ����� ����� �������        :
;       � ����� �������� �����                                   :
;                                                                :
;    �����:     CY = 1 ������� ������� ��� ����� �����           :
;               DSKETTE_STATUS = ��� ������                      :
;-----------------------------------------------------------------
MED_CHANGE          PROC    NEAR
        CALL    READ_DSKCHNG            ; ������ ��������� ����� ����� �������
        JZ      MC_OUT                  ; ����� ���� �� ������
        AND     DSK_STATE[DI],NOT MED_DET       ; ������� ��������� ��� �����-
						; ��������� ���������


        MOV     CX,DI                   ; CL = ����� ���������
        MOV     AL,1                    ; ��� ����� ������
        SHL     AL,CL                   ; ��������������� �������
        NOT     AL
        CLI                             ; ������ ����������
        AND     MOTOR_STATUS,AL         ; ������� ������ ��� ���������
        STI                             ; ���������� ����������
        CALL    MOTOR_ON                ; ������� ������

;--------  ����� �������

        CALL    DISK_RESET              ; �����
        MOV     CH,01H                  ; ������������ �� 1 �������
        CALL    SEEK                    ; ���������� ������������
        XOR     CH,CH                   ; ������������ �� 0 �������
        CALL    SEEK                    ; ���������� ������������
        MOV     DISKETTE_STATUS,MEDIA_CHANGE    ; ���������� � �������

OK1:    CALL    READ_DSKCHNG            ; �������� ����� �����
        JZ	MC_OUT                  ; ???
;        JZ      OK2                     ; IF ACTIVE, NO DISKETTE, TIMEOUT

OK4:    MOV     DISKETTE_STATUS,TIME_OUT  ; ����� ����� ���� �������� ����
OK2:
        STC                             ; �������, ��������� CY
        RET
MC_OUT:
        CLC                             ; �� �������
        RET
MED_CHANGE          ENDP
; ----------------------------------------------------------------
;  SEND_RATE                                                     :
;       ������� �������� �������� � NEC                          :
;      ����:    DI = ����� ���������                             :
;    �����:     ���                                              :
;  �������:     DX                                               :
;-----------------------------------------------------------------
SEND_RATE          PROC    NEAR

        PUSH    AX
        AND     LASTRATE,NOT SEND_MSK   ; ������� �������� ���������� ���������
        MOV     AL,DSK_STATE[DI]        ; ��������� �������� ������� ���������
        AND     AL,SEND_MSK             ; �������������� ���� ��������
        OR      LASTRATE,AL             ; ���������� ����� �������� ��� �����-
					; ���� ��������
        ROL     AL,1                    ; ������������ ����� � ������ �������
        ROL	AL,1
        MOV     DX,03F7H                ; ��������� ����� ��������
        OUT     DX,AL
        POP     AX
        RET
SEND_RATE          ENDP

; ----------------------------------------------------------------
;  CHK_LASTRATE                                                  :
;       �������� ���������� �������� ��������                    :
;      ����:                                                     :
;       DI = ����� ���������                                     :
;    �����:                                                      :
;       ZF = 1 �������� �� ��, ��� � � ���������� ��������       :
;       ZF = 0 ������                                            :
;  �������:  BX                                                  :
;-----------------------------------------------------------------
CHK_LASTRATE          PROC    NEAR
        PUSH    AX
        MOV     AH,LASTRATE             ; ��������� �������� ���������� ��������
        MOV     AL,DSK_STATE[DI]        ; ��������� �������� ����� ���������
        AND     AX,0C0C0H ;SEND_MSK*X   ; ������ ���� ��������
        CMP     AL,AH                   ; ��������� � ����������
                                        ; ZF = 1 �������� �� ��
        POP     AX
        RET
CHK_LASTRATE          ENDP
