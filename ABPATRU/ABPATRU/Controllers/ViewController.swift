/*
 *
    Proj: ABPATRU
    Author: Adi Pslr < adipislaru97@gmail.com >
    Date: 9 May 2018
 *
 */

import UIKit

class TableViewController: UITableViewController
{
    var arrayOfUsers = [ User ]( )
    var selectedIndex: Int = 0
    
    override func viewDidLoad( )
    {
        view.backgroundColor = UIColor( red: 252.0/255, green: 236.0/255, blue: 201.0/255, alpha: 1.0 )

        UserManager.loadUsers( )
        {
            ( ret ) in
            
            self.arrayOfUsers = ret
        
            DispatchQueue.main.async
            {
                self.tableView.reloadData( )
            }
        }
    }
    
    override func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath )
    {
        self.selectedIndex = indexPath.row
        
        performSegue( withIdentifier: "segue", sender: self )
    }
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        let secondController = segue.destination as! DetailsController
        
        secondController.myUser = self.arrayOfUsers[ self.selectedIndex ]
    }
    
    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int
    {
        return arrayOfUsers.count
    }
    
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let cell = Bundle.main.loadNibNamed( "CustomCell", owner: self, options: nil )?.first as! CustomCell
        
        cell.mainImage.image = UIImage( data: arrayOfUsers[ indexPath.row ].getImage( ) )
        cell.mainImage.layer.cornerRadius = cell.mainImage.frame.size.width / 2
        cell.mainImage.clipsToBounds = true
        
        if( indexPath.row % 2 == 0 )
        {
            cell.backgroundColor = UIColor( red: 252.0/255, green: 236.0/255, blue: 201.0/255, alpha: 1.0 )
        }
        else
        {
            cell.backgroundColor = UIColor( red: 204.0/255, green: 230.0/255, blue: 244.0/255, alpha: 1.0 )
        }
        
        cell.mainLabel.text = arrayOfUsers[ indexPath.row ].getName( )
        
        return cell
    }
    
    override func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> CGFloat
    {
        return 190
    }
}

