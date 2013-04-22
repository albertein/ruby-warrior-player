# Short notice:

# This player actually had good intentions, it eat well, burshed his teeth after every meal and tried to have enough 
# rest after every battle, it even got into melee combat when possible (That's is, always). 
#But round after round he found that good intentions alone would not bring him anywhere. 

# On level 9 is when ephiphany struck him, why bother if after every level we need to think again our strategy?, why 
# bother with a sweaty meele combat if an arrow would do the same job, taking just a few more turns but way safer?
# Why should you rest, if using bow and arrow would make it almost useless?
# And why bother to release all the captives if they don't even thank you for?.

# Overall, i removed a bunch of lines of code, (about 40 i guess), and i still got a B grade, not ideal but i fair
# tradeoff i guess.

# What could i try to do in order to increase the grading?. Exploring the whole level before going into the stairs.
# Besides that i think that trying to use more the melee figth (as i started) woul decrease the time needed to complete
# the tower, but, for that to woork i would need to try to guess what type of unit i'm looking at (How more easy
# would it be if our friendly warry could tell apart wizards, and archers apart from sludges? room.wizard? anyone?).

#Anyways, it was fun, maybe i could try to improve it later on.

class Player
  attr_accessor :state

  def initialize()
    self.state = :walk
    @first_round = true
  end

  def play_turn(warrior)

    direction = :forward # We used to start going backwards first, trying to find missing captives,
                         # but then we found about pivoy!, why walk backwards when we can turn around?, 
                         # i felt so silly for those many rounds walking backwards, how embarrasing!
                         # we are keeping the direction for it's nostalgic value. It's a good fella.

    warrior = stub_warrior warrior
    if @first_round # Start always walking to the left, why? because it works best on most scenarios
      @first_round = false
      warrior.pivot!
      return
    end

    if warrior.feel.wall? #Dead end? better go back
      warrior.pivot!
      return
    end

    with_captive = false 
    with_enemies = false # Inocent 'till proven gulty
    warrior.look(direction).each do |room| #Look if the next feature is either a enemy or a captive
      if room.captive? and not with_enemies 
        with_captive = true
        break
      elsif room.enemy? 
        with_enemies = true
        break
      end
    end

    if warrior.feel(direction).empty?
      if with_enemies #Shoot mighty arrow if there is an enemy (We are sure that there are not captives, for real ;)
        warrior.shoot! 
      elsif state == :attack #If we were having a fun melee and just won, it's time to lick our wounds
        self.state = :flee
        warrior.backoff! direction
      else #Carry on
        warrior.walk! direction
      end
    elsif warrior.feel(direction).captive? #Sorry, but the princess is in another castle
      warrior.rescue! direction
    elsif warrior.feel(direction).enemy? #Melee time, so sad it's no longer used #sadpanda
      self.state = :attack
      warrior.attack! direction
    else
      puts "I've no idea what i'm doing"
    end
  end

  def stub_warrior(warrior)
    if @stub.nil? #If we don't have a stub object, let's make a new one
      @stub = StubbedWarrior.new(warrior)
    end
    @stub.warrior = warrior
    @stub
  end
end

class StubbedWarrior #This was supposed to stub unavailable methods early on the dungeon
                     #But after simplifying the strategy i think that it was not that nessesary anymore.
  attr_accessor :warrior

  def initialize(warrior)

    @stub_true = StubTrue.new #Slutty stub object, always says Yes!
    @stub_false = StubFalse.new #This stub object always says no, but deepth inside him his soul screams YES!!

  end    

  def backoff!(direction) #I think this method is not being used anymore, #this was supossed to make the player
                          #go back if he was on peril danger, to allow him to heal, anyway he is a good guy and
                          #don't deserve to be deleted.... yet.
    opposite = {:forward => :backward, :backward => :forward} # Also :vi => :emacs
    warrior.walk! opposite[direction] #Literate programming, hu?
  end


  def method_missing(method, *arguments)
    if warrior.respond_to? method #If we are looking for a method that the real warrior knows, better ask him first
      return warrior.send method, *arguments
    end

    stub_true = [:feel] #This was supposed to be a list of the commands that needed to be stubed as true
                        #Now i feel silly for my smarty one element list
    if stub_true.include? method
      return @stub_true
    else
      return @stub_false #We actually are never using it, they always choose the slutty stub first.
    end
  end
end

class StubTrue
  def method_missing(method)
    true #enough
  end
end

class StubFalse
  def method_missing(method)
    false
  end
end