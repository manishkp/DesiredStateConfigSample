Configuration DeploymentDesiredState
{
    # Parameters
    Param(
       [Parameter(Mandatory=$True,Position=1)]
       [string]$ComputerName	
    )

    $PortalPath = "${env:ProgramFiles(x86)}\MyCompany\Portal\Website"   
    $PortalCertificateThumbPrint ="132A034D6A2A3FC44CF87AA65D83BC1280DD4323"

    Import-DscResource -Module xWebAdministration

    # A Configuration block can have zero or more Node blocks
    Node $ComputerName
    {
        # Next, specify one or more resource blocks
        # WindowsFeature is one of the built-in resources you can use in a Node block
        # This example ensures the Web Server (IIS) role is installed
        WindowsFeature IISServerRole
        {
            Ensure = "Present"
            Name = "Web-Server"  
        }
        
        WindowsFeature WebServerASPNetRole
        {
            Ensure = "Present"
            Name = "Web-ASP-Net45"  
        }
        
        WindowsFeature MSMQ
        {
            Ensure = "Present"
            Name = "MSMQ"  
        }

         
        # Stop the default website
        xWebsite DefaultSite 
        {
            Ensure          = "Absent"
            Name            = "Default Web Site"
            State           = "Stopped"
            PhysicalPath    = "C:\inetpub\wwwroot"
            DependsOn       = "[WindowsFeature]IISServerRole"
        }


        File PortalPath
        {
           DestinationPath = $PortalPath
           Type = 'Directory'
           Ensure = 'Present'
        }   

        xWebsite StsWebSite 
        {
            Ensure          = "Present"
            Name            = "PortalWeb"
            State           = "Started"
            PhysicalPath    = $PortalPath
            DependsOn       = "[File]PortalPath"
            ApplicationPool = "PortalWeb"
            BindingInfo = MSFT_xWebBindingInformation
                    {
                        Protocol = "HTTPS"
                        Port = 8888                    
                        CertificateThumbPrint = $PortalCertificateThumbPrint
                        # for this to work we need to update "C:\Program Files\WindowsPowerShell\Modules\xWebAdministration\DSCResources\MSFT_xWebsite\MSFT_xWebsite.schema.mof" to allow "My"
                        CertificateStoreName = "My"
                    }
        }  
     
        Service MyService
        {
            Name = "My.WindowsService"
            StartupType = "Automatic"
            State = "Running"
        }
    }
} 
