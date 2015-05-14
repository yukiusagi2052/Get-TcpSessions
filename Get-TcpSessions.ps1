<#
  Title    : Get-TcpSession.ps1
  Version  : 0.1
  Updated  : 2015/5/14

  Tested   : Powershell 4.0
#>

function Get-TcpSessions {
  [OutputType('System.Management.Automation.PSObject')]
  [CmdletBinding()]
  Param()

  #エラーハンドリングを指定
  $ErrorActionPreference = "Stop"

  ##Tcpセッション情報取得（外部コマンド）
  try{
    $Data = Invoke-Expression "netstat -an"
  } catch {
    Write-TextLog -OutFileName "Info" -Message "Netstatエラー"
    Write-EventLog -LogName Application -EntryType Information -Source $EventSourceName -EventId 1001 -Message "Netstatコマンド実行エラー"
  }

  [int]$Tcp_LISTENING    = 0
  [int]$Tcp_SYN_RECEIVED = 0
  [int]$Tcp_SYN_SENT     = 0
  [int]$Tcp_ESTABLISHED  = 0
  [int]$Tcp_FIN_WAIT_1   = 0
  [int]$Tcp_FIN_WAIT_2   = 0
  [int]$Tcp_CLOSING      = 0
  [int]$Tcp_TIME_WAIT    = 0
  [int]$Tcp_CLOSE_WAIT   = 0
  [int]$Tcp_LAST_ACK     = 0

  #Netstat -an 結果の集計
  For ($i=4; $i -lt $Data.Length; $i++) {

      If ( $Data[$i].Contains("TCP") -and !$Data[$i].Contains("[::]") ) {
          #TCPを含むとき
          If     ( $Data[$i].Contains("LISTENING")    ){ $Tcp_LISTENING++    }
          ElseIf ( $Data[$i].Contains("SYN_RECEIVED") ){ $Tcp_SYN_RECEIVED++ }
          ElseIf ( $Data[$i].Contains("SYN_SENT")     ){ $Tcp_SYN_SENT++     }
          ElseIf ( $Data[$i].Contains("ESTABLISHED")  ){ $Tcp_ESTABLISHED++  }
          ElseIf ( $Data[$i].Contains("FIN_WAIT_1")   ){ $Tcp_FIN_WAIT_1++   }
          ElseIf ( $Data[$i].Contains("FIN_WAIT_2")   ){ $Tcp_FIN_WAIT_2++   }
          ElseIf ( $Data[$i].Contains("CLOSING")      ){ $Tcp_CLOSING++      }
          ElseIf ( $Data[$i].Contains("TIME_WAIT")    ){ $Tcp_TIME_WAIT++    }
          ElseIf ( $Data[$i].Contains("CLOSE_WAIT")   ){ $Tcp_CLOSE_WAIT++   }
          ElseIf ( $Data[$i].Contains("LAST_ACK")     ){ $Tcp_LAST_ACK++     }
      }
  }

  #セッション数 合計を計算
  $Tcp_TOTAL = $Tcp_SYN_RECEIVED + $Tcp_SYN_SENT + $Tcp_ESTABLISHED `
  + $Tcp_FIN_WAIT_1 + $Tcp_FIN_WAIT_2 + $Tcp_CLOSING + $Tcp_TIME_WAIT + $Tcp_CLOSE_WAIT + $Tcp_LAST_ACK

  #戻り値
  $object = New-Object PSObject -Property @{
    LISTENING    = $Tcp_LISTENING
    SYN_RECEIVED = $Tcp_SYN_RECEIVED
    SYN_SENT     = $Tcp_SYN_SENT
    ESTABLISHED  = $Tcp_ESTABLISHED
    FIN_WAIT_1   = $Tcp_FIN_WAIT_1
    FIN_WAIT_2   = $Tcp_FIN_WAIT_2
    CLOSING      = $Tcp_CLOSING
    TIME_WAIT    = $Tcp_TIME_WAIT
    CLOSE_WAIT   = $Tcp_CLOSE_WAIT
    LAST_ACK     = $Tcp_LAST_ACK
    TOTAL        = $Tcp_TOTAL
  }
  Write-Output $object

} #Function Get-TcpSession ここまで
