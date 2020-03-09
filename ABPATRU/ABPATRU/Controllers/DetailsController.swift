import UIKit

class DetailsController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var nume: UILabel!
    
    @IBOutlet weak var locatie: UILabel!
    
    @IBOutlet weak var badges: UILabel!
    
    var myUser: User? = nil
    
    @IBAction func enter( _ sender: Any )
    {
        performSegue( withIdentifier: "segue2", sender: self )
    }
    
    override func viewDidLoad( )
    {
        super.viewDidLoad( )
        
        image.layer.cornerRadius = image.frame.size.width/2
        image.clipsToBounds = true
        
        nume.text = "👤 " + myUser!.getName( )
        locatie.text = myUser!.getLocation( )
        badges.text = myUser!.getBadges( )
        image.image = UIImage( data: myUser!.getImage( ) )
    }
}
