FasdUAS 1.101.10   ��   ��    k             l     �� ��    6 0	***********************************************       	  l     �� 
��   
 ' !		Size warning FolderActionScript    	     l     �� ��    7 1 	***********************************************         l     ������  ��        l      �� ��   +%
	This script is a folder action script.
	It needs to be attached to a folder - and will act on files and folders added to that folder.

	It will check the size of the folder when items are added.
	Then warn if the size is too large.
	
	Bugs:
	The script is triggered soon after the start of the copy 
	- so if the file is large then the size is calculated before the copy operation completes.
	This means that a large copy could quite easily go over the limit without warning you.
	
	The next add file operation would correctly warn you though...

         l     ������  ��        l     ������  ��        l     ������  ��        l     �� ��     	Config Properties         l     ������  ��        l     ��  ��     ) #	The folder limit size in megabytes      ! " ! j     �� #�� 0 limitinmegs limitInMegs # m     ����  "  $ % $ l     ������  ��   %  & ' & l     �� (��   ( A ;	How close to the limit do we want the warnings to start?      '  ) * ) l     �� +��   + 0 *	e.g. 0.5 would start warning at half full    *  , - , j    �� .�� 20 proximitywarningpercent proximityWarningPercent . m     / / ?�       -  0 1 0 l     ������  ��   1  2 3 2 l     �� 4��   4  	Growl Config    3  5 6 5 j    �� 7�� (0 scriptgrowlappname scriptGrowlAppName 7 m     8 8 % Folder Size Warning AppleScript    6  9 : 9 j   	 �� ;�� ,0 allnotificationslist allNotificationsList ; c   	  < = < J   	  > >  ? @ ? m   	 
 A A  Script Error    @  B C B m   
  D D  Limit Proximity Warning    C  E F E m     G G  Limit Breached    F  H�� H m     I I  InternalDebugging   ��   = m    ��
�� 
list :  J K J j    �� L�� 40 defaultnotificationslist defaultNotificationsList L c     M N M J     O O  P Q P m     R R  Script Error    Q  S T S m     U U  Limit Proximity Warning    T  V�� V m     W W  Limit Breached   ��   N m    ��
�� 
list K  X Y X l     ������  ��   Y  Z [ Z l     ������  ��   [  \ ] \ l     ������  ��   ]  ^ _ ^ l     �� `��   `   Warn when run normally.    _  a b a i     c d c I     ������
�� .aevtoappnull  �   � ****��  ��   d k      e e  f g f n     h i h I    �������� $0 registerforgrowl registerForGrowl��  ��   i  f      g  j k j n    l m l I    �� n���� 0 
quickerror 
quickError n  o�� o m     p p O IThis is a Folder Action Script - it should not be run as a normal script.   ��  ��   m  f     k  q r q l   �� s��   s J D	But run it anyway - on a specific folder - for debugging purposes.	    r  t u t r     v w v c     x y x m     z z  :users:diggory:a:    y m    ��
�� 
alis w o      ���� 0 
testfolder 
testFolder u  {�� { n    | } | I    �� ~���� "0 checkfoldersize checkFolderSize ~  ��  o    ���� 0 
testfolder 
testFolder��  ��   }  f    ��   b  � � � l     ������  ��   �  � � � l     ������  ��   �  � � � l     �� ���   � F @The handler for responding to when items are added to a folder:     �  � � � i     # � � � I     �� � �
�� .facofgetnull���     alis � o      ���� 0 this_folder   � �� ���
�� 
flst � o      ���� 0 these_items  ��   � k      � �  � � � l     �� ���   � O I 	'these_items' will contain a list of file references to the added items    �  � � � l     �� ���   � ? 9	But we do not care about those - just the parent folder.    �  ��� � n     � � � I    �� ����� "0 checkfoldersize checkFolderSize �  ��� � o    ���� 0 this_folder  ��  ��   �  f     ��   �  � � � l     ������  ��   �  � � � l     ������  ��   �  � � � l     ������  ��   �  � � � i  $ ' � � � I      �� ����� "0 checkfoldersize checkFolderSize �  ��� � l      ��� � o      ���� 0 folderalias folderAlias��  ��  ��   � Q    G � � � � k   + � �  � � � n    � � � I    �������� $0 registerforgrowl registerForGrowl��  ��   �  f     �  � � � n  	  � � � I   
 �� ����� (0 quickinternaldebug quickInternalDebug �  ��� � m   
  � �  LimitWarn starts...   ��  ��   �  f   	 
 �  � � � l   ������  ��   �  � � � O    � � � r     � � � n     � � � 1    ��
�� 
phys � l    ��� � o    ���� 0 folderalias folderAlias��   � o      ���� 0 
foldersize 
folderSize � m     � ��null     ߀��  

Finder.app��@� �0�L�Ȑ 7���p 
 � h 0   )       �(�K� ��Ԑ�MACS   alis    b  WideBoy                    ��.1H+    

Finder.app                                                       2����        ����  	                CoreServices    ��.1      ���      
  
  
  .WideBoy:System:Library:CoreServices:Finder.app   
 F i n d e r . a p p    W i d e B o y  &System/Library/CoreServices/Finder.app  / ��   �  � � � l   �� ���   � = 7	Call it twice - for some reason the finder needs this.    �  � � � O   ) � � � r    ( � � � c    & � � � ^    $ � � � l   " ��� � n    " � � � 1     "��
�� 
phys � l     ��� � o     ���� 0 folderalias folderAlias��  ��   � m   " #����  � m   $ %��
�� 
nmbr � o      ���� (0 foldersizeinkbytes folderSizeInKBytes � m     � �  � � � l  * *������  ��   �  � � � r   * / � � � ^   * - � � � o   * +���� (0 foldersizeinkbytes folderSizeInKBytes � m   + ,����  � o      ���� (0 foldersizeinmbytes folderSizeInMBytes �  � � � n  0 < � � � I   1 <�� ����� (0 quickinternaldebug quickInternalDebug �  ��� � c   1 8 � � � l  1 6 ��� � b   1 6 � � � b   1 4 � � � m   1 2 � �  Folder size...     � o   2 3���� (0 foldersizeinmbytes folderSizeInMBytes � m   4 5 � � 	  MB   ��   � m   6 7��
�� 
TEXT��  ��   �  f   0 1 �  � � � l  = =������  ��   �  � � � l  = =�� ���   �   are we over the limit?    �  � � � Z   =) � ��� � � ?   = D � � � o   = >���� (0 foldersizeinmbytes folderSizeInMBytes � o   > C���� 0 limitinmegs limitInMegs � k   G x � �  � � � l  G G�� ���   �   Danger Will Robinson!    �  � � � n  G M � � � I   H M�� ����� (0 quickinternaldebug quickInternalDebug �  ��� � m   H I    We are over the limit!!    ��  ��   �  f   G H �  l  N N�����  �    r   N Q m   N O # You have Breached your limit!    o      �~�~ $0 growldescription growlDescription 	 l  R R�}�|�}  �|  	 

 O  R v I  V u�{�z
�{ .notifygrnull��� ��� null�z   �y
�y 
name l 	 X Y�x m   X Y  Limit Breached   �x   �w
�w 
titl l 	 Z ]�v m   Z ]  Warning!   �v   �u
�u 
desc l 	 ` a�t o   ` a�s�s $0 growldescription growlDescription�t   �r
�r 
appl o   d i�q�q (0 scriptgrowlappname scriptGrowlAppName �p�o
�p 
iurl m   l o Y S/System/Library/CoreServices/Software Update.app/Contents/Resources/exclamation.tif   �o   m   R SLnull     ߀�� `N�GrowlHelperApp.appL��� 7��ـ   l h h   )       �(�K� ��٠ �GRRR   alis    �  WideBoy                    ��.1H+   `N�GrowlHelperApp.app                                              `N��m�P        ����  	                	Resources     ��.1      �m�@     `N� `N� `N� +m �� ��  |  bWideBoy:Users:diggory:Library:PreferencePanes:Growl.prefPane:Contents:Resources:GrowlHelperApp.app  &  G r o w l H e l p e r A p p . a p p    W i d e B o y  ZUsers/diggory/Library/PreferencePanes/Growl.prefPane/Contents/Resources/GrowlHelperApp.app  /    ��   �n l  w w�m�l�m  �l  �n  ��   � k   {)   !"! l  { {�k#�k  # 0 *	are we close enough to the limit to warn?   " $%$ r   { �&'& ^   { �()( o   { |�j�j (0 foldersizeinmbytes folderSizeInMBytes) o   | ��i�i 0 limitinmegs limitInMegs' o      �h�h 0 percentfull percentFull% *+* n  � �,-, I   � ��g.�f�g (0 quickinternaldebug quickInternalDebug. /�e/ c   � �010 l  � �2�d2 b   � �343 b   � �565 m   � �77  How full?     6 ]   � �898 o   � ��c�c 0 percentfull percentFull9 m   � ��b�b d4 m   � �::  %   �d  1 m   � ��a
�a 
TEXT�e  �f  -  f   � �+ ;<; l  � ��`�_�`  �_  < =�^= Z   �)>?�]�\> ?   � �@A@ o   � ��[�[ 0 percentfull percentFullA o   � ��Z�Z 20 proximitywarningpercent proximityWarningPercent? k   �%BB CDC l  � ��YE�Y  E  	We should warn.   D FGF l  � ��X�W�X  �W  G HIH r   � �JKJ l  � �L�VL ^   � �MNM l  � �O�UO \   � �PQP o   � ��T�T 0 percentfull percentFullQ o   � ��S�S 20 proximitywarningpercent proximityWarningPercent�U  N l  � �R�RR \   � �STS m   � ��Q�Q T o   � ��P�P 20 proximitywarningpercent proximityWarningPercent�R  �V  K o      �O�O <0 percentabovewarningthreshold percentAboveWarningThresholdI UVU l  � ��NW�N  W 8 2	There are five different priorities in growl.				   V XYX r   � �Z[Z I  � ��M\]
�M .sysorondlong    ��� doub\ l  � �^�L^ \   � �_`_ l  � �a�Ka ]   � �bcb o   � ��J�J <0 percentabovewarningthreshold percentAboveWarningThresholdc m   � ��I�I �K  ` m   � ��H�H �L  ] �Gd�F
�G 
dired m   � ��E
�E olierndS�F  [ l     e�De o      �C�C 0 growlpriority growlPriority�D  Y fgf l  � ��B�A�B  �A  g hih n  � �jkj I   � ��@l�?�@ (0 quickinternaldebug quickInternalDebugl m�>m c   � �non l  � �p�=p b   � �qrq b   � �sts b   � �uvu m   � �ww d ^This is a courtesy notice - you are getting close to your limit...  percent above warnThresh:    v ]   � �xyx o   � ��<�< <0 percentabovewarningthreshold percentAboveWarningThresholdy m   � ��;�; dt m   � �zz   %   -- GrowlPriority:    r o   � ��:�: 0 growlpriority growlPriority�=  o m   � ��9
�9 
TEXT�>  �?  k  f   � �i {|{ l  � ��8�7�8  �7  | }~} r   � �� I  � ��6��
�6 .sysorondlong    ��� doub� l  � ���5� ]   � ���� o   � ��4�4 0 percentfull percentFull� m   � ��3�3 d�5  � �2��1
�2 
dire� m   � ��0
�0 olierndS�1  � o      �/�/  0 nicepercentage nicePercentage~ ��� r   � ���� b   � ���� b   � ���� m   � ��� - 'you are getting close to your limit...    � o   � ��.�.  0 nicepercentage nicePercentage� m   � ���  % full.   � o      �-�- $0 growldescription growlDescription� ��� l  � ��,�+�,  �+  � ��� O  �#��� I "�*�)�
�* .notifygrnull��� ��� null�)  � �(��
�( 
name� l 	��'� m  ��  Limit Proximity Warning   �'  � �&��
�& 
titl� l 		��%� m  	��  Limit Proximity Warning   �%  � �$��
�$ 
desc� l 	��#� o  �"�" $0 growldescription growlDescription�#  � �!��
�! 
appl� l 
�� � o  �� (0 scriptgrowlappname scriptGrowlAppName�   � ���
� 
prio� o  �� 0 growlpriority growlPriority�  � m   � � ��� l $$���  �  �  �]  �\  �^   � ��� l **���  �  �   � R      ���
� .ascrerr ****      � ****� o      �� 0 	errortext 	errorText� ���
� 
errn� o      �� 
0 errnum  �   � n 3G��� I  4G���� 0 
quickerror 
quickError� ��� b  4C��� b  4?��� b  4=��� b  49��� m  47�� ' !It's all gone a bit Pete Tong! :    � o  78�� 0 	errortext 	errorText� m  9<��  (   � o  =>�� 
0 errnum  � m  ?B��  )   �  �  �  f  34 � ��� l     ��
�  �
  � ��� l     �	��	  �  � ��� l     ���  �  � ��� l     ���  �  � ��� l     ���  �  � ��� l     ���  �  		SubRoutines   � ��� l     � ���   ��  � ��� l     ������  ��  � ��� l     ������  ��  � ��� l     �����  �  	Growl Support Routines   � ��� i  ( +��� I      �������� $0 registerforgrowl registerForGrowl��  ��  � O     ��� k    �� ��� l   �����  � 1 + Make a list of all the notification types    � ��� l   �����  � ' ! that this script will ever send:   � ��� l   ������  ��  � ��� l   �����  � &   Register our script with growl.   � ��� l   �����  � 7 1 You can optionally (as here) set a default icon    � ��� l   �����  � ' ! for this script's notifications.   � ���� I   �����
�� .registernull��� ��� null��  � ����
�� 
appl� l 	  ���� o    ���� (0 scriptgrowlappname scriptGrowlAppName��  � ����
�� 
anot� l 
  ���� o    ���� ,0 allnotificationslist allNotificationsList��  � ����
�� 
dnot� l 
  ���� o    ���� 40 defaultnotificationslist defaultNotificationsList��  � �����
�� 
iapp� m    ��  Finder   ��  ��  � m     � ��� l     ������  ��  � ��� l     ������  ��  � ��� i  , /��� I      ������� 0 
quickerror 
quickError� ���� o      ���� 0 	errortext 	errorText��  ��  � O        k      l   ����   #        Send a Notification...    �� I   ����
�� .notifygrnull��� ��� null��   ��	
�� 
name l 	  
��
 m      Script Error   ��  	 ��
�� 
titl l 	  	�� m    	 0 *LimitWarn AppleScript ran into an error...   ��   ��
�� 
desc l 	 
 �� l  
 �� c   
  o   
 ���� 0 	errortext 	errorText m    ��
�� 
TEXT��  ��   ��
�� 
appl o    ���� (0 scriptgrowlappname scriptGrowlAppName ����
�� 
iurl m     Y S/System/Library/CoreServices/Software Update.app/Contents/Resources/exclamation.tif   ��  ��   m     �  l     ������  ��    l     ������  ��    l     ������  ��    !  i  0 3"#" I      ��$���� (0 quickinternaldebug quickInternalDebug$ %��% o      ���� 0 	debugnote 	debugNote��  ��  # O     &'& I   ����(
�� .notifygrnull��� ��� null��  ( ��)*
�� 
name) l 	  +��+ m    ,,  InternalDebugging   ��  * ��-.
�� 
titl- l 	  	/��/ m    	00  Debugging note...   ��  . ��12
�� 
desc1 l 	 
 3��3 l  
 4��4 c   
 565 o   
 ���� 0 	debugnote 	debugNote6 m    ��
�� 
TEXT��  ��  2 ��78
�� 
appl7 o    ���� (0 scriptgrowlappname scriptGrowlAppName8 ��9��
�� 
iurl9 m    :: ] W/System/Library/CoreServices/Software Update.app/Contents/Resources/Installcomplete.tif   ��  ' m     ! ;��; l     ������  ��  ��       ��<�� / 8=>?@ABCD��  < ������������������������ 0 limitinmegs limitInMegs�� 20 proximitywarningpercent proximityWarningPercent�� (0 scriptgrowlappname scriptGrowlAppName�� ,0 allnotificationslist allNotificationsList�� 40 defaultnotificationslist defaultNotificationsList
�� .aevtoappnull  �   � ****
�� .facofgetnull���     alis�� "0 checkfoldersize checkFolderSize�� $0 registerforgrowl registerForGrowl�� 0 
quickerror 
quickError�� (0 quickinternaldebug quickInternalDebug�� = ��E�� E   A D G I> ��F�� F   R U W? �� d����GH��
�� .aevtoappnull  �   � ****��  ��  G  H �� p�� z�������� $0 registerforgrowl registerForGrowl�� 0 
quickerror 
quickError
�� 
alis�� 0 
testfolder 
testFolder�� "0 checkfoldersize checkFolderSize�� )j+  O)�k+ O��&E�O)�k+ @ �� �����IJ��
�� .facofgetnull���     alis�� 0 this_folder  �� ������
�� 
flst�� 0 these_items  ��  I ������ 0 this_folder  �� 0 these_items  J ���� "0 checkfoldersize checkFolderSize�� )�k+  A �� �����KL���� "0 checkfoldersize checkFolderSize�� ��M�� M  ���� 0 folderalias folderAlias��  K ������������~�}�|�{�z�� 0 folderalias folderAlias�� 0 
foldersize 
folderSize�� (0 foldersizeinkbytes folderSizeInKBytes�� (0 foldersizeinmbytes folderSizeInMBytes�� $0 growldescription growlDescription� 0 percentfull percentFull�~ <0 percentabovewarningthreshold percentAboveWarningThreshold�} 0 growlpriority growlPriority�|  0 nicepercentage nicePercentage�{ 0 	errortext 	errorText�z 
0 errnum  L +�y ��x ��w�v�u � ��t �s�r�q�p�o�n�m7�l:�k�j�i�hwz�����g�fN����e�y $0 registerforgrowl registerForGrowl�x (0 quickinternaldebug quickInternalDebug
�w 
phys�v 
�u 
nmbr
�t 
TEXT
�s 
name
�r 
titl
�q 
desc
�p 
appl
�o 
iurl�n 

�m .notifygrnull��� ��� null�l d�k 
�j 
dire
�i olierndS
�h .sysorondlong    ��� doub
�g 
prio�f 0 	errortext 	errorTextN �d�c�b
�d 
errn�c 
0 errnum  �b  �e 0 
quickerror 
quickError��H-)j+  O)�k+ O� ��,E�UO� ��,�!�&E�UO��!E�O)�%�%�&k+ O�b    6)�k+ O�E�O� !*���a a �a b  a a a  UOPY ��b   !E�O)a �a  %a %�&k+ O�b   ��b  kb  !E�O�a  la a l E�O)a �a  %a %�%�&k+ O�a  a a l E�Oa  �%a !%E�O� !*�a "�a #a �a b  a $�a  UOPY hOPW X % &)a '�%a (%�%a )%k+ *B �a��`�_OP�^�a $0 registerforgrowl registerForGrowl�`  �_  O  P �]�\�[�Z��Y�X
�] 
appl
�\ 
anot
�[ 
dnot
�Z 
iapp�Y 
�X .registernull��� ��� null�^ � *�b  �b  �b  ��� UC �W��V�UQR�T�W 0 
quickerror 
quickError�V �SS�S S  �R�R 0 	errortext 	errorText�U  Q �Q�Q 0 	errortext 	errorTextR �P�O�N�M�L�K�J�I
�P 
name
�O 
titl
�N 
desc
�M 
TEXT
�L 
appl
�K 
iurl�J 

�I .notifygrnull��� ��� null�T � *������&�b  ��� UD �H#�G�FTU�E�H (0 quickinternaldebug quickInternalDebug�G �DV�D V  �C�C 0 	debugnote 	debugNote�F  T �B�B 0 	debugnote 	debugNoteU �A,�@0�?�>�=�<:�;�:
�A 
name
�@ 
titl
�? 
desc
�> 
TEXT
�= 
appl
�< 
iurl�; 

�: .notifygrnull��� ��� null�E � *������&�b  ��� Uascr  ��ޭ