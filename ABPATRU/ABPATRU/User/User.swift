/*
 *
    Proj: ABPATRU
    Author: Adi Pslr < adipislaru97@gmail.com >
    Date: 9 May 2018
 *
 */

import Foundation

class User
{
    private let id: Int
    private let img: Data
    private let name: String
    private let location: String
    private let badges: String
    
    init( id: Int, img: Data, name: String, location: String, badges: String )
    {
        self.id = id
        self.img = img
        self.name = name
        self.location = location
        self.badges = badges
    }
    
    func getName( ) -> String
    {
        return name;
    }
    
    func getLocation( ) -> String
    {
        return location;
    }
    
    func getBadges( ) -> String
    {
        return badges;
    }
    
    func getImage( ) -> Data
    {
        return self.img;
    }
}
