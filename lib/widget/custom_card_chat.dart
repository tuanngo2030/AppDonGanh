import 'package:don_ganh_app/models/chat_model.dart';
import 'package:flutter/material.dart';

class CustomCardChat extends StatelessWidget {
  const CustomCardChat({super.key, required this.chatModel});
  final Message chatModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, '/chatscreen');
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Icon(Icons.percent),
            ),
            title: Text(
              chatModel.msgByUserId,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          
            subtitle: Row(
              children: [
                Icon(Icons.done_all),
                SizedBox(width: 3,),
                Text(
                  chatModel.text,
                  style: TextStyle(
                    fontSize: 13
                  ),
                )
              ],
            ),

            trailing: Text('${chatModel.createdAt}'),
          ),
        ],
      ),
    );
     
  }
}