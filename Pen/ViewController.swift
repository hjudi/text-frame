//
//  ViewController.swift
//  Pen
//
//  Created by Hazim Judi on 2016-05-09.
//  Copyright © 2016 LC. All rights reserved.
//

import UIKit

let ps = NSMutableParagraphStyle();

class MainViewController: UIViewController {
	
	var textView : UITextView!
	var button : Button!
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.spaceAndDotSet?.addCharactersInString(".")
		
		self.textView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
		self.textView.backgroundColor = .clearColor()
		self.textView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
		self.textView.clipsToBounds = false
		self.textView.editable = false
		self.textView.selectable = false
		
		ps.lineSpacing = 10
		
		self.textView.attributedText = NSAttributedString(string: s, attributes: [NSParagraphStyleAttributeName: ps, NSFontAttributeName: UIFont.systemFontOfSize(19, weight: UIFontWeightRegular)])
		self.view.addSubview(self.textView)
		
		self.layoutManager = self.textView.layoutManager
		
		self.textView.gestureRecognizers?.forEach({ r in
			
			if r.isKindOfClass(UIPanGestureRecognizer.self) == true {
				
				(r as! UIPanGestureRecognizer).minimumNumberOfTouches = 2
			}
		})
		
		let gr = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
		gr.maximumNumberOfTouches = 1
		self.textView.addGestureRecognizer(gr)
		
		
		//
		
		
		self.button = Button(frame: CGRect(x: self.view.bounds.width-85, y: self.view.bounds.height-88, width: 85, height: 85))
		self.view.addSubview(self.button)
	}
	
	var firstTouchPoint : CGPoint?
	var currentTouchPoint : CGPoint?
	
	var firstTouchScrollPoint : CGPoint?
	
	var firstCharacterIndex : Int?
	var latestCharacterIndex : Int?
	
	var layoutManager : NSLayoutManager!
	
	var hideSelectionTimer : NSTimer?
	
	var spaceSet : NSCharacterSet? = NSCharacterSet.whitespaceAndNewlineCharacterSet()
	var spaceAndDotSet : NSMutableCharacterSet? = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
	
	func didPan(r: UIPanGestureRecognizer) {
		
		self.layoutManager.ensureLayoutForTextContainer(self.textView.textContainer)
		
		if r.state == .Began {
			
			print(r.locationInView(self.view), r.locationInView(self.textView))
			
			self.firstTouchPoint = r.locationInView(self.textView)
			self.firstTouchPoint?.x -= self.textView.textContainerInset.left
			self.firstTouchPoint?.y -= self.textView.textContainerInset.top
			
			self.currentTouchPoint = self.firstTouchPoint
			self.firstTouchScrollPoint = self.textView.contentOffset
			
			self.firstCharacterIndex = self.layoutManager.characterIndexForPoint(self.firstTouchPoint!, inTextContainer: self.textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
			
			self.resetExistingSelections()
			self.markSelectedCharacters()
			
			print("Began @ \(self.currentTouchPoint)")
		}
		else if r.state == .Changed {
			
			print(r.locationInView(self.view), r.locationInView(self.textView))
			
			self.currentTouchPoint = r.locationInView(self.textView)
			self.currentTouchPoint?.x -= self.textView.textContainerInset.left
			self.currentTouchPoint?.y -= self.textView.textContainerInset.top
			
			self.latestCharacterIndex = self.layoutManager.characterIndexForPoint(self.currentTouchPoint!, inTextContainer: self.textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
			
			//self.resetExistingSelections()
			self.markSelectedCharacters()
			
			print("Changed -> \(self.currentTouchPoint)")
		}
		else if r.state == .Ended {
			
			//
			print("Ended @ \(self.currentTouchPoint)")
			
			self.firstTouchPoint = nil
			self.currentTouchPoint = nil
			self.firstTouchScrollPoint = nil
			
			self.resetSelectedCharacters()
			self.hideSelectionTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(resetExistingSelections), userInfo: nil, repeats: false)
		}
		else if r.state == .Cancelled {
			
			
		}
	}
	
	var firstMarkIndex : Int?
	var latestMarkIndex : Int?
	
	func resetSelectedCharacters() {
		
		self.firstCharacterIndex = nil
		self.latestCharacterIndex = nil
		self.firstMarkIndex = nil
		self.latestMarkIndex = nil
	}
	
	func markSelectedCharacters() {
		
		if self.latestCharacterIndex == nil {
			
			self.latestCharacterIndex = self.firstCharacterIndex!+1
		}
		
		self.firstMarkIndex = 0
		self.latestMarkIndex = self.textView.textStorage.length-1
		
		// Adjusting to nearest word start/end
		
		let r1 = (self.textView.textStorage.string as NSString).rangeOfCharacterFromSet(self.spaceAndDotSet!, options: .BackwardsSearch, range: NSMakeRange(0, self.firstCharacterIndex!))
		
		if r1.location != NSNotFound {
			
			self.firstMarkIndex = r1.location.advancedBy(1)
		}
		
		let r2 = (self.textView.textStorage.string as NSString).rangeOfCharacterFromSet(self.spaceSet!, options: .LiteralSearch, range: NSMakeRange(self.latestCharacterIndex!, self.textView.textStorage.length-self.latestCharacterIndex!))
		
		if r2.location != NSNotFound {
			
			self.latestMarkIndex = r2.location
		}
		
		var lastWordIndex = self.firstMarkIndex
		
		let r3 = (self.textView.textStorage.string as NSString).rangeOfCharacterFromSet(self.spaceAndDotSet!, options: .BackwardsSearch, range: NSMakeRange(0, self.latestMarkIndex!))
		
		if r3.location != NSNotFound {
			
			lastWordIndex = r3.location
		}
		else {
			
			lastWordIndex = self.latestMarkIndex
		}
		
		
		// Marking
		
		if (self.latestMarkIndex!-self.firstMarkIndex!) > self.textView.textStorage.length {
			
			return
		}
		
		if (self.latestMarkIndex!-self.firstMarkIndex!) < 0 {
			
			return
		}
		
		self.textView.textStorage.addAttributes([NSForegroundColorAttributeName: UIColor(white: 0, alpha: 1), NSBackgroundColorAttributeName: UIColor(white: 1, alpha: 1)], range: NSMakeRange(0, self.textView.textStorage.length))
		
		self.textView.textStorage.addAttributes([NSForegroundColorAttributeName: UIColor(white: 0.3, alpha: 1), NSBackgroundColorAttributeName: UIColor(white: 0.9, alpha: 1)], range: NSMakeRange(self.firstMarkIndex!, self.latestMarkIndex!-self.firstMarkIndex!))
		
		if lastWordIndex! > self.firstMarkIndex! {
			
			
			self.textView.textStorage.addAttributes([NSForegroundColorAttributeName: UIColor(white: 0.3, alpha: 1), NSBackgroundColorAttributeName: UIColor(white: 0.84, alpha: 1)], range: NSMakeRange(lastWordIndex!, self.latestMarkIndex!-lastWordIndex!))
		}
		
	}

	func resetExistingSelections() {
		
		self.textView.textStorage.addAttributes([NSBackgroundColorAttributeName: UIColor.clearColor(), NSForegroundColorAttributeName: UIColor.blackColor()], range: NSMakeRange(0, self.textView.textStorage.length))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}


}

let s = "I. A man must not only consider how daily his life wasteth and decreaseth, but this also, that if he live long, he cannot be certain, whether his understanding shall continue so able and sufficient, for either discreet consideration, in matter of businesses; or for contemplation: it being the thing, whereon true knowledge of things both divine and human, doth depend. For if once he shall begin to dote, his respiration, nutrition, his imaginative, and appetitive, and other natural faculties, may still continue the same: he shall find no want of them. But how to make that right use of himself that he should, how to observe exactly in all things that which is right and just, how to redress and rectify all wrong, or sudden apprehensions and imaginations, and even of this particular, whether he should live any longer or no, to consider duly; for all such things, wherein the best strength and vigour of the mind is most requisite; his power and ability will be past and gone. Thou must hasten therefore; not only because thou art every day nearer unto death than other, but also because that intellective faculty in thee, whereby thou art enabled to know the true nature of things, and to order all thy actions by that knowledge, doth daily waste and decay: or, may fail thee before thou die.\n\nII. This also thou must observe, that whatsoever it is that naturally doth happen to things natural, hath somewhat in itself that is pleasing and delightful: as a great loaf when it is baked, some parts of it cleave as it were, and part asunder, and make the crust of it rugged and unequal, and yet those parts of it, though in some sort it be against the art and intention of baking itself, that they are thus cleft and parted, which should have been and were first made all even and uniform, they become it well nevertheless, and have a certain peculiar property, to stir the appetite. So figs are accounted fairest and ripest then, when they begin to shrink, and wither as it were. So ripe olives, when they are next to putrefaction, then are they in their proper beauty. The hanging down of grapes—the brow of a lion, the froth of a foaming wild boar, and many other like things, though by themselves considered, they are far from any beauty, yet because they happen naturally, they both are comely, and delightful; so that if a man shall with a profound mind and apprehension, consider all things in the world, even among all those things which are but mere accessories and natural appendices as it were, there will scarce appear anything unto him, wherein he will not find matter of pleasure and delight. So will he behold with as much pleasure the true rictus of wild beasts, as those which by skilful painters and other artificers are imitated. So will he be able to perceive the proper ripeness and beauty of old age, whether in man or woman: and whatsoever else it is that is beautiful and alluring in whatsoever is, with chaste and continent eyes he will soon find out and discern. Those and many other things will he discern, not credible unto every one, but unto them only who are truly and familiarly acquainted, both with nature itself, and all natural things.\n\nIII. Hippocrates having cured many sicknesses, fell sick himself and died. The Chaldeans and Astrologians having foretold the deaths of divers, were afterwards themselves surprised by the fates. Alexander and Pompeius, and Caius Caesar, having destroyed so many towns, and cut off in the field so many thousands both of horse and foot, yet they themselves at last were fain to part with their own lives. Heraclitus having written so many natural tracts concerning the last and general conflagration of the world, died afterwards all filled with water within, and all bedaubed with dirt and dung without. Lice killed Democritus; and Socrates, another sort of vermin, wicked ungodly men. How then stands the case? Thou hast taken ship, thou hast sailed, thou art come to land, go out, if to another life, there also shalt thou find gods, who are everywhere. If all life and sense shall cease, then shalt thou cease also to be subject to either pains or pleasures; and to serve and tend this vile cottage; so much the viler, by how much that which ministers unto it doth excel; the one being a rational substance, and a spirit, the other nothing but earth and blood.\n\nIV. Spend not the remnant of thy days in thoughts and fancies concerning other men, when it is not in relation to some common good, when by it thou art hindered from some other better work. That is, spend not thy time in thinking, what such a man doth, and to what end: what he saith, and what he thinks, and what he is about, and such other things or curiosities, which make a man to rove and wander from the care and observation of that part of himself, which is rational, and overruling. See therefore in the whole series and connection of thy thoughts, that thou be careful to prevent whatsoever is idle and impertinent: but especially, whatsoever is curious and malicious: and thou must use thyself to think only of such things, of which if a man upon a sudden should ask thee, what it is that thou art now thinking, thou mayest answer This, and That, freely and boldly, that so by thy thoughts it may presently appear that in all thee is sincere, and peaceable; as becometh one that is made for society, and regards not pleasures, nor gives way to any voluptuous imaginations at all: free from all contentiousness, envy, and suspicion, and from whatsoever else thou wouldest blush to confess thy thoughts were set upon. He that is such, is he surely that doth not put off to lay hold on that which is best indeed, a very priest and minister of the gods, well acquainted and in good correspondence with him especially that is seated and placed within himself, as in a temple and sacrary: to whom also he keeps and preserves himself unspotted by pleasure, undaunted by pain; free from any manner of wrong, or contumely, by himself offered unto himself: not capable of any evil from others: a wrestler of the best sort, and for the highest prize, that he may not be cast down by any passion or affection of his own; deeply dyed and drenched in righteousness, embracing and accepting with his whole heart whatsoever either happeneth or is allotted unto him. One who not often, nor without some great necessity tending to some public good, mindeth what any other, either speaks, or doth, or purposeth: for those things only that are in his own power, or that are truly his own, are the objects of his employments, and his thoughts are ever taken up with those things, which of the whole universe are by the fates or Providence destinated and appropriated unto himself. Those things that are his own, and in his own power, he himself takes order, for that they be good: and as for those that happen unto him, he believes them to be so. For that lot and portion which is assigned to every one, as it is unavoidable and necessary, so is it always profitable. He remembers besides that whatsoever partakes of reason, is akin unto him, and that to care for all men generally, is agreeing to the nature of a man: but as for honour and praise, that they ought not generally to be admitted and accepted of from all, but from such only, who live according to nature. As for them that do not, what manner of men they be at home, or abroad; day or night, how conditioned themselves with what manner of conditions, or with men of what conditions they moil and pass away the time together, he knoweth, and remembers right well, he therefore regards not such praise and approbation, as proceeding from them, who cannot like and approve themselves.\n\nV.\n\nDo nothing against thy will, nor contrary to the community, nor without due examination, nor with reluctancy. Affect not to set out thy thoughts with curious neat language. Be neither a great talker, nor a great undertaker. Moreover, let thy God that is in thee to rule over thee, find by thee, that he hath to do with a man; an aged man; a sociable man; a Roman; a prince; one that hath ordered his life, as one that expecteth, as it were, nothing but the sound of the trumpet, sounding a retreat to depart out of this life with all expedition. One who for his word or actions neither needs an oath, nor any man to be a witness."

