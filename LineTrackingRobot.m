%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% @author: Yameni Gleen und Stefan Göb %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Matrikelnummer: 1275517 und 1251133  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Last edited on 09-10-2020            %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clear the workspace 
clear all; close all; clc;

%Declare thr portnumber and the board
a = arduino('COM3','Uno');

%Creat an instence of the library
sub_zumorobot = zumorobot(a);

%Needed variables
counter=0;
calibrating=0;

while(1)
    %Get the sensor values
    [s1,s2,s3,s4,s5,s6] = sub_zumorobot.readReflectanceSensor(a);
    
    %Display the values on the command window
    disp([s1,s2,s3,s4,s5,s6])
    
    %The first 6 sensors values will not be use because the sensors need a
    %little bit of time to be calibrated
    if calibrating<5
        calibrating = calibrating + 1;
        continue
    end
    
    %Comparing the sensor values
    %We will use the comparing value of 2000 and not 2500 to compromise 
    %possible sensors errors.
    
    %Default Case -no sensor reading
    if (s1<2000 && s2<2000 && s3<2000 && s4<2000 && s5<2000 && s6<2000) 
        sub_zumorobot.motor(a,0.00,0,0.00,0)
        counter = counter+1; 
        
        %Stop the Robot if the sensors doesn't get 10 consecutive reading
        if counter==10
            break
        end
        continue   
        
    %Case1 -Moving left at a junction 
    %The left turn at a Junction is a little bit more Agressive to ensure
    %that the Robot won't go out of the Non-reflecting line.
    elseif ((s1>2000 || s2>2000) && (s5>2000 || s6>2000)) || (s3+s4+s5+s6>8000)
             sub_zumorobot.motor(a,0.050,0,0.30,0)
             sub_zumorobot.buzzer(a,1000);
             fprintf('Turning left(Junction)')  

        
    %Case2 -Moving foward
    %When ever the middle sensors(s1,s2) are true(high) the Robot is on the
    %line and mostly on the middle of the line
    elseif (s3>2000 && s4>2000)  
             sub_zumorobot.motor(a,0.17,0,0.17,0)
             sub_zumorobot.buzzer(a,200);
             fprintf('Moving foward')
        
    %Case3 -Turning left
    %Here we compare the values of the sensors s1,s2 ans s4,s5
    %(the sensors on the extrem rigth with those on the left) 
    elseif (s4>2000 || s5>2000) && (s2<2000 && s1<2000 ) 
            sub_zumorobot.motor(a,0.075,0,0.25,0)
            sub_zumorobot.buzzer(a,300);
            fprintf('Turning left')                         
            
    %Case4 -Turning right 
    %Here we compare the values of the sensors s5,s6 ans s2,s3
    %(the sensors on the extrem left with those on the right)     
    elseif (s5<2000 && s6<2000) && (s2>2000 || s3>2000)  
             sub_zumorobot.motor(a,0.25,0,0.075,0)
             sub_zumorobot.buzzer(a,400);
             fprintf('Turning right')   
   
    %The Last 2 cases are the most aggressive, This takes place usually 
    %when the Robot is about to run out of the Non-reflecting line.
    %For this reason whe use a stationary and aggressive change of
    %direction to make sure we get back on the Non-reflecting line. 
    
    %Case5 -Moving aggressively to the right
    elseif  (s1>2000 && s6<2000)
              sub_zumorobot.motor(a,0.3,0,0.3,1)
              sub_zumorobot.buzzer(a,900);
              fprintf('Strong right')
              
    %Case6 -Moving aggressively to the left
    elseif (s1<2000 && s6>2000)
              sub_zumorobot.motor(a,0.3,1,0.3,0)
              sub_zumorobot.buzzer(a,800);
              fprintf('Strong left')
              
    end
    
    %Reset the counter if the programm doesn't execute the Default case
    if 1
         counter=0;
    end
   
     fprintf('\n')
end



